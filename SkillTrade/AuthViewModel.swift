import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isInitializing = true
    @Published var showAuthScreen = false
    @Published var userRole: String = ""
    @Published var currentUserID: String = ""
    @Published var currentUserName: String = ""
    @Published var currentUserEmail: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    @Published var pendingBookingProvider: Provider?

    private let db = Firestore.firestore()
    private var didAttachAuthListener = false

    func listenToAuthChanges() {
        guard !didAttachAuthListener else { return }
        didAttachAuthListener = true

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.currentUserID = user.uid
                self.currentUserEmail = user.email ?? ""
                self.fetchUserData(uid: user.uid)
            } else {
                DispatchQueue.main.async {
                    self.resetSession()
                    self.isInitializing = false
                }
            }
        }
    }

    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.resetSession()
                    self.isInitializing = false
                    return
                }

                let data = snapshot?.data()
                self.userRole = data?["role"] as? String ?? ""
                self.currentUserName = data?["name"] as? String ?? ""
                self.isLoggedIn = true
                self.isInitializing = false
                self.showAuthScreen = false
                if self.userRole != "homeowner" {
                    self.pendingBookingProvider = nil
                }
            }
        }
    }

    func signUp(email: String, password: String, name: String, role: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            guard let uid = result?.user.uid else { return }

            // Write to users collection
            self.db.collection("users").document(uid).setData([
                "uid": uid, "name": name, "email": email,
                "role": role, "createdAt": Timestamp(date: Date())
            ])

            // If provider, also create provider profile
            if role == "provider" {
                self.db.collection("providers").document(uid).setData([
                    "uid": uid, "name": name, "email": email,
                    "services": [], "bio": "", "rating": 0.0,
                    "reviewCount": 0, "location": "", "availability": [:],
                    "createdAt": Timestamp(date: Date())
                ])
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        pendingBookingProvider = nil
        showAuthScreen = false
        try? Auth.auth().signOut()
    }

    func beginManualLogin() {
        errorMessage = ""
        showAuthScreen = true
    }

    func cancelManualLogin() {
        errorMessage = ""
        showAuthScreen = false
        pendingBookingProvider = nil
    }

    func beginBookingLogin(for provider: Provider) {
        pendingBookingProvider = provider
        beginManualLogin()
    }

    func clearPendingBooking() {
        pendingBookingProvider = nil
    }

    private func resetSession() {
        isLoggedIn = false
        userRole = ""
        currentUserID = ""
        currentUserName = ""
        currentUserEmail = ""
    }
}
