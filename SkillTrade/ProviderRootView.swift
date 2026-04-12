import SwiftUI

struct ProviderRootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = ProviderViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                ProviderDashboardView()
                    .environmentObject(vm)
                    .navigationTitle("Dashboard")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out", role: .destructive) {
                                auth.signOut()
                            }
                            .font(.subheadline)
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "list.clipboard")
            }

            NavigationStack {
                ProviderMyProfileView()
                    .environmentObject(vm)
                    .navigationTitle("My Profile")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out", role: .destructive) {
                                auth.signOut()
                            }
                            .font(.subheadline)
                        }
                    }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}
