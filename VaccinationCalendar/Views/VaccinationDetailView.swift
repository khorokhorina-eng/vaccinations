import SwiftUI

struct VaccinationDetailView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    let vaccination: Vaccination
    
    @State private var notes: String
    @State private var vaccineType: String
    @State private var isEditing = false
    
    init(viewModel: VaccinationViewModel, vaccination: Vaccination) {
        self.viewModel = viewModel
        self.vaccination = vaccination
        self._notes = State(initialValue: vaccination.notes)
        self._vaccineType = State(initialValue: vaccination.vaccineType)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vaccination.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(vaccination.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleVaccinationCompletion(vaccination)
                        }) {
                            Image(systemName: vaccination.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundColor(vaccination.isCompleted ? .green : .gray)
                        }
                    }
                    
                    HStack {
                        Label(vaccination.recommendedAge.displayText, systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if vaccination.isRequired {
                            Label("Обязательная", systemImage: "exclamationmark.triangle.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        } else {
                            Label("Рекомендуемая", systemImage: "info.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Status
                if let completedDate = vaccination.completedDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Статус")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Выполнено \(completedDate.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Vaccine Type
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Тип вакцины")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Image(systemName: isEditing ? "checkmark" : "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if isEditing {
                        TextField("Введите тип вакцины", text: $vaccineType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                viewModel.updateVaccinationVaccineType(vaccination, vaccineType: vaccineType)
                                isEditing = false
                            }
                    } else {
                        if vaccineType.isEmpty {
                            Text("Не указано")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Text(vaccineType)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Заметки")
                        .font(.headline)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: notes) { newValue in
                            viewModel.updateVaccinationNotes(vaccination, notes: newValue)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Детали прививки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        VaccinationDetailView(
            viewModel: VaccinationViewModel(),
            vaccination: Vaccination(
                name: "Гепатит B",
                description: "Первая вакцинация против вирусного гепатита B",
                recommendedAge: AgeRange(fromAge: 0, toAge: 0),
                isRequired: true
            )
        )
    }
}