import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore

    var body: some View {
        Group {
            if dataStore.isFirstLaunch {
                OnboardingView()
            } else {
                CalendarView()
            }
        }
        .onAppear {
            dataStore.load()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(DataStore.preview)
    }
}