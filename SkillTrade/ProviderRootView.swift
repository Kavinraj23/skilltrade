import SwiftUI

struct ProviderRootView: View {
    @StateObject private var vm = ProviderViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                ProviderDashboardView()
                    .environmentObject(vm)
                    .navigationTitle("Dashboard")
            }
            .tabItem {
                Label("Dashboard", systemImage: "list.clipboard")
            }

            NavigationStack {
                ProviderMyProfileView()
                    .environmentObject(vm)
                    .navigationTitle("My Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}
