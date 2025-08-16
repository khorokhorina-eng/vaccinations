import SwiftUI

struct ContentView: View {
    @StateObject private var vaccinationManager = VaccinationManager()
    
    var body: some View {
        Group {
            if vaccinationManager.appData.isOnboardingCompleted {
                VaccinationCalendarView(vaccinationManager: vaccinationManager)
            } else {
                OnboardingView(vaccinationManager: vaccinationManager)
            }
        }
        .preferredColorScheme(.light) // Можно убрать для поддержки тёмной темы
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}