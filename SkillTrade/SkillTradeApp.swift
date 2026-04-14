import SwiftUI
import Firebase

@main
struct SkillTradeApp: App {
    init() { FirebaseApp.configure() }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
