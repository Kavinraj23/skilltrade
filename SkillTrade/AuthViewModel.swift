import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    // Flag set during sign-up so the listener doesn't
    // try to fetch a doc that hasn't been written yet
    private var isSigningUp = false

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { [weak self] in
                await self?.handleAuthChange(firebaseUser)
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func handleAuthChange(_ firebaseUser: FirebaseAuth.User?) async {
        // Skip if signUp() is managing state directly
        guard !isSigningUp else { return }

        guard let firebaseUser else {
            currentUser = nil
            isLoading = false
            return
        }

        do {
            currentUser = try await fetchUserDoc(uid: firebaseUser.uid)
        } catch {
            // Doc missing — could be a timing issue on first launch, just clear state
            currentUser = nil
            try? Auth.auth().signOut()
        }
        isLoading = false
    }

    // MARK: - Sign Up

    func signUp(name: String, email: String, password: String, role: Role) async {
        errorMessage = nil
        isSigningUp = true
        defer { isSigningUp = false }

        do {
            // 1. Create Firebase Auth account
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            // 2. Write users/{uid} — await so doc exists before anything reads it
            let user = User(id: uid, name: name, email: email, role: role)
            try await db.collection("users").document(uid).setData(from: user)

            // 3. Write providers/{uid} for provider sign-ups
            if role == .provider {
                let provider = Provider(
                    id: uid,
                    name: name,
                    businessName: "",
                    services: [],
                    bio: "",
                    city: "",
                    category: .handyman,
                    averageRating: 0.0,
                    reviewCount: 0
                )
                try await db.collection("providers").document(uid).setData(from: provider)
            }

            // 4. Set currentUser directly — no need to re-fetch what we just wrote
            currentUser = user
            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            // handleAuthChange fires and sets currentUser + isLoading
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Sign Out

    func signOut() {
        try? Auth.auth().signOut()
        currentUser = nil
    }

    // MARK: - Helpers

    private func fetchUserDoc(uid: String) async throws -> User {
        let doc = try await db.collection("users").document(uid).getDocument()
        return try doc.data(as: User.self)
    }
}
