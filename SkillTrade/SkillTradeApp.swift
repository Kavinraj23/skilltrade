import SwiftUI
import FirebaseCore

@main
struct SkillTradeApp: App {
    @StateObject private var auth = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RoleSelectionView()
                .environmentObject(auth)
        }
    }
}
