import SwiftUI

struct HomeownerRootView: View {
    @StateObject private var vm = HomeownerViewModel()

    var body: some View {
        NavigationStack {
            HomeownerHomeView()
                .environmentObject(vm)
                .navigationTitle("SkillTrade")
        }
    }
}
