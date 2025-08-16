import SwiftUI

struct VaccinationDetailView: View {
    let vaccination: Vaccination
    let vaccinationManager: VaccinationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isCompleted: Bool = false
    @State private var completedDate: Date = Date()
    @State private var notes: String = ""
    @State private var vaccineName: String = ""
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Vaccination Info Header
                    VaccinationInfoHeader(vaccination: vaccination, vaccinationManager: vaccinationManager)
                    
                    // Status Toggle
                    StatusToggleSection(isCompleted: $isCompleted)
                    
                    if isCompleted {
                        // Completed Date
                        CompletedDateSection(
                            completedDate: $completedDate,
                            showingDatePicker: $showingDatePicker
                        )
                        
                        // Vaccine Name
                        VaccineNameSection(vaccineName: $vaccineName)
                        
                        // Notes
                        NotesSection(notes: $notes)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Детали прививки")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            )
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $completedDate)
        }
        .onAppear {
            loadCurrentData()
        }
    }
    
    private func loadCurrentData() {
        if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id) {
            isCompleted = record.isCompleted
            completedDate = record.completedDate ?? Date()
            notes = record.notes
            vaccineName = record.vaccineName ?? ""
        }
    }
    
    private func saveChanges() {
        if isCompleted {
            vaccinationManager.markVaccinationCompleted(
                vaccinationId: vaccination.id,
                date: completedDate,
                notes: notes,
                vaccineName: vaccineName.isEmpty ? nil : vaccineName
            )
        } else {
            vaccinationManager.markVaccinationIncomplete(vaccinationId: vaccination.id)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Vaccination Info Header

struct VaccinationInfoHeader: View {
    let vaccination: Vaccination
    let vaccinationManager: VaccinationManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and Status
            HStack {
                statusIcon
                    .font(.system(size: 50))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    statusText
                        .font(.headline)
                    
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // Vaccination Details
            VStack(alignment: .leading, spacing: 12) {
                Text(vaccination.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(vaccination.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Label(vaccination.ageDescription, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Label(vaccination.isRequired ? "Обязательная" : "Дополнительная", 
                          systemImage: vaccination.isRequired ? "exclamationmark.circle" : "plus.circle")
                        .font(.subheadline)
                        .foregroundColor(vaccination.isRequired ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var statusIcon: some View {
        Group {
            if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id) {
                if record.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if vaccinationManager.isVaccinationOverdue(vaccination) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                } else if vaccinationManager.isVaccinationDue(vaccination) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var statusText: Text {
        Group {
            if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id) {
                if record.isCompleted {
                    Text("Выполнено")
                        .foregroundColor(.green)
                } else if vaccinationManager.isVaccinationOverdue(vaccination) {
                    Text("Просрочено")
                        .foregroundColor(.red)
                } else if vaccinationManager.isVaccinationDue(vaccination) {
                    Text("Пора делать")
                        .foregroundColor(.orange)
                } else {
                    Text("Ожидание")
                        .foregroundColor(.gray)
                }
            } else {
                Text("Ожидание")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var statusDescription: String {
        let childAge = vaccinationManager.getChildAgeInMonths()
        if childAge < vaccination.ageInMonths {
            let monthsToWait = vaccination.ageInMonths - childAge
            return "Ещё \(monthsToWait) мес."
        } else if childAge == vaccination.ageInMonths {
            return "Подходящий возраст"
        } else {
            let monthsLate = childAge - vaccination.ageInMonths
            return "Опоздание на \(monthsLate) мес."
        }
    }
}

// MARK: - Status Toggle Section

struct StatusToggleSection: View {
    @Binding var isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статус прививки")
                .font(.headline)
            
            Toggle("Прививка выполнена", isOn: $isCompleted)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Completed Date Section

struct CompletedDateSection: View {
    @Binding var completedDate: Date
    @Binding var showingDatePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дата выполнения")
                .font(.headline)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text(completedDate, style: .date)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Vaccine Name Section

struct VaccineNameSection: View {
    @Binding var vaccineName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Название вакцины (необязательно)")
                .font(.headline)
            
            TextField("Например: Пентаксим, Инфанрикс", text: $vaccineName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Notes Section

struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заметки (необязательно)")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Date Picker Sheet (Reused from OnboardingView)

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Дата выполнения",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Дата выполнения")
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

// MARK: - Preview

struct VaccinationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VaccinationDetailView(
            vaccination: Vaccination(
                id: "test",
                name: "Тестовая прививка",
                description: "Описание тестовой прививки",
                ageInMonths: 3,
                isRequired: true,
                countryCode: "RU"
            ),
            vaccinationManager: VaccinationManager()
        )
    }
}