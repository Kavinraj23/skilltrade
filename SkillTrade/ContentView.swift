import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()

    private var deferredBookingBinding: Binding<Provider?> {
        Binding(
            get: {
                if authVM.isLoggedIn && authVM.userRole == "homeowner" {
                    return authVM.pendingBookingProvider
                }
                return nil
            },
            set: { newValue in
                if newValue == nil {
                    authVM.clearPendingBooking()
                }
            }
        )
    }

    var body: some View {
        Group {
            if authVM.isInitializing {
                ProgressView("Loading...")
            } else if authVM.isLoggedIn {
                if authVM.userRole == "homeowner" {
                    HomeownerTabView().environmentObject(authVM)
                } else {
                    ProviderTabView().environmentObject(authVM)
                }
            } else {
                GuestLandingTabView().environmentObject(authVM)
            }
        }
        .onAppear { authVM.listenToAuthChanges() }
        .sheet(isPresented: $authVM.showAuthScreen) {
            AuthView()
                .environmentObject(authVM)
        }
        .sheet(item: deferredBookingBinding) { provider in
            DeferredBookingRequestView(provider: provider)
                .environmentObject(authVM)
        }
    }
}
