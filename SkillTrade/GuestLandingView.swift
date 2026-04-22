import SwiftUI

struct GuestLandingTabView: View {
    var body: some View {
        TabView {
            HomeownerSearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            AuthView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}
