import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                if authVM.userRole == "homeowner" {
                    HomeownerTabView().environmentObject(authVM)
                } else {
                    ProviderTabView().environmentObject(authVM)
                }
            } else {
                AuthView().environmentObject(authVM)
            }
        }
        .onAppear { authVM.listenToAuthChanges() }
    }
}
