import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userRole: String = ""
    @Published var currentUserID: String = ""
    @Published var currentUserName: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.currentUserID = user.uid
                self.fetchUserData(uid: user.uid)
            } else {
                self.isLoggedIn = false
                self.userRole = ""
                self.currentUserID = ""
                self.currentUserName = ""
            }
        }
    }

    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.userRole = data["role"] as? String ?? ""
                self.currentUserName = data["name"] as? String ?? ""
                self.isLoggedIn = true
            }
        }
    }

    func signUp(email: String, password: String, name: String, role: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
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
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
