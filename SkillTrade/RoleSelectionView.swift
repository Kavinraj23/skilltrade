import SwiftUI

// RoleSelectionView is the app's root router.
// It reads the authenticated user's role and sends them to the right flow.
// If no session exists it shows LoginView.

struct RoleSelectionView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if let user = auth.currentUser {
                switch user.role {
                case .homeowner:
                    HomeownerRootView()
                case .provider:
                    ProviderRootView()
                }
            } else {
                LoginView()
            }
        }
    }
}
