import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var birthDate = Date()
    @State private var selectedCountry: String = ""
    @State private var showAlert = false

    private var countries: [String] {
        dataStore.availableCountries()
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дата рождения")) {
                    DatePicker("Выберите дату", selection: $birthDate, displayedComponents: .date)
                }

                Section(header: Text("Страна")) {
                    Picker("Страна", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country)
                        }
                    }
                }
            }
            .navigationTitle("Профиль ребёнка")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if selectedCountry.isEmpty {
                            showAlert = true
                        } else {
                            dataStore.setupChildProfile(birthDate: birthDate, country: selectedCountry)
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Пожалуйста, выберите страну."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(DataStore.preview)
    }
}