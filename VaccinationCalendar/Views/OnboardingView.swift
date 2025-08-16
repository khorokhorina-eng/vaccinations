import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    @State private var childName = ""
    @State private var birthDate = Date()
    @State private var selectedCountry = "Россия"
    
    private let countries = [
        "Россия", "США", "Германия", "Франция", "Великобритания", 
        "Канада", "Австралия", "Япония", "Китай", "Индия"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    Text("Календарь прививок")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Введите информацию о вашем ребёнке для создания персонального календаря прививок")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя ребёнка")
                            .font(.headline)
                        
                        TextField("Введите имя", text: $childName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дата рождения")
                            .font(.headline)
                        
                        DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Страна проживания")
                            .font(.headline)
                        
                        Picker("Страна", selection: $selectedCountry) {
                            ForEach(countries, id: \.self) { country in
                                Text(country).tag(country)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    viewModel.updateChild(
                        name: childName,
                        birthDate: birthDate,
                        country: selectedCountry
                    )
                }) {
                    Text("Начать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(childName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(childName.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView(viewModel: VaccinationViewModel())
}