import SwiftUI

struct HomeownerRootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = HomeownerViewModel()

    var body: some View {
        NavigationStack {
            HomeownerHomeView()
                .environmentObject(vm)
                .navigationTitle("SkillTrade")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out", role: .destructive) {
                            auth.signOut()
                        }
                        .font(.subheadline)
                    }
                }
        }
    }
}
