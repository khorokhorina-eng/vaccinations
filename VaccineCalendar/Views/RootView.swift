import SwiftUI

struct RootView: View {
	@EnvironmentObject private var store: AppStore

	var body: some View {
		Group {
			if store.profile == nil {
				OnboardingView()
			} else {
				CalendarHomeView()
			}
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView()
			.environmentObject(AppStore())
	}
}