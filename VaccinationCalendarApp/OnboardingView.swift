import SwiftUI

struct OnboardingView: View {
    @ObservedObject var vaccinationManager: VaccinationManager
    @State private var childName: String = ""
    @State private var birthDate: Date = Date()
    @State private var selectedCountry: Country = Country.availableCountries.first!
    @State private var showingDatePicker = false
    @State private var showingCountryPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.pink)
                    
                    Text("Календарь прививок")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Добро пожаловать! Давайте настроим календарь прививок для вашего ребёнка")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Form
                VStack(spacing: 24) {
                    // Child Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя ребёнка")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Введите имя", text: $childName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Birth Date Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дата рождения")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Text(birthDate, style: .date)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Country Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Страна проживания")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showingCountryPicker = true
                        }) {
                            HStack {
                                Text(selectedCountry.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    createChild()
                }) {
                    HStack {
                        Text("Продолжить")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $birthDate)
        }
        .sheet(isPresented: $showingCountryPicker) {
            CountryPickerSheet(selectedCountry: $selectedCountry)
        }
    }
    
    private var isFormValid: Bool {
        !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func createChild() {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        vaccinationManager.setChild(
            name: trimmedName,
            birthDate: birthDate,
            country: selectedCountry
        )
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Дата рождения",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Дата рождения")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Готово") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.semibold)
            )
        }
    }
}

// MARK: - Country Picker Sheet

struct CountryPickerSheet: View {
    @Binding var selectedCountry: Country
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(Country.availableCountries) { country in
                Button(action: {
                    selectedCountry = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(country.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if country.id == selectedCountry.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Выберите страну")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(vaccinationManager: VaccinationManager())
    }
}