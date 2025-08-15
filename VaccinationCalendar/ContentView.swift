import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VaccinationViewModel()
    
    var body: some View {
        Group {
            if viewModel.child.isOnboarded {
                VaccinationCalendarView(viewModel: viewModel)
            } else {
                OnboardingView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}