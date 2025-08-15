import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VaccinationViewModel()
    
    var body: some View {
        Group {
            if viewModel.showingOnboarding {
                OnboardingView(viewModel: viewModel)
            } else {
                VaccinationCalendarView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}