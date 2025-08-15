import SwiftUI

@main
struct ChildVaccinationApp: App {
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
        }
    }
}