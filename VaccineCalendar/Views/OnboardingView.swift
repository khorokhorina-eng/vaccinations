import SwiftUI

struct OnboardingView: View {
	@EnvironmentObject private var store: AppStore
	@State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
	@State private var selectedCountryCode: String = CountryService.supported.first?.code ?? "RU"

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Дата рождения")) {
					DatePicker("Выберите дату", selection: $dateOfBirth, displayedComponents: .date)
				}
				Section(header: Text("Страна")) {
					Picker("Выберите страну", selection: $selectedCountryCode) {
						ForEach(CountryService.supported) { country in
							Text(country.name).tag(country.code)
						}
					}
				}
				Section {
					Button(action: {
						store.setProfile(dateOfBirth: dateOfBirth, countryCode: selectedCountryCode)
					}) {
						Text("Продолжить")
							.frame(maxWidth: .infinity)
					}
				}
			}
			.navigationTitle("Календарь прививок")
		}
	}
}

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingView()
			.environmentObject(AppStore())
	}
}