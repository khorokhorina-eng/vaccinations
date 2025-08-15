import SwiftUI

struct VaccinationDetailView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    let vaccination: Vaccination
    
    @State private var isCompleted = false
    @State private var completedDate = Date()
    @State private var notes = ""
    @State private var vaccineType = ""
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                VStack(alignment: .leading, spacing: 8) {
                    Text(vaccination.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(vaccination.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Статус
                HStack {
                    Image(systemName: vaccination.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(vaccination.isCompleted ? .green : .gray)
                        .font(.title2)
                    
                    Text(vaccination.isCompleted ? "Выполнено" : "Не выполнено")
                        .font(.headline)
                        .foregroundColor(vaccination.isCompleted ? .green : .gray)
                    
                    Spacer()
                    
                    if vaccination.isOverdue {
                        Text("Просрочено")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    } else if vaccination.isDueSoon {
                        Text("Скоро")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Возраст
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text("Рекомендуемый возраст: \(vaccination.ageInMonths) месяцев")
                        .font(.body)
                    
                    Spacer()
                }
                
                // Тип прививки
                HStack {
                    Image(systemName: "syringe")
                        .foregroundColor(.purple)
                    
                    Text("Тип: \(vaccination.isRequired ? "Обязательная" : "Рекомендуемая")")
                        .font(.body)
                    
                    Spacer()
                }
                
                // Информация о выполнении
                if vaccination.isCompleted {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Информация о выполнении")
                            .font(.headline)
                        
                        if let date = vaccination.completedDate {
                            HStack {
                                Image(systemName: "calendar.badge.checkmark")
                                    .foregroundColor(.green)
                                Text("Дата: \(date, style: .date)")
                                Spacer()
                            }
                        }
                        
                        if !vaccination.vaccineType.isEmpty {
                            HStack {
                                Image(systemName: "pills")
                                    .foregroundColor(.blue)
                                Text("Вакцина: \(vaccination.vaccineType)")
                                Spacer()
                            }
                        }
                        
                        if !vaccination.notes.isEmpty {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                Text("Заметки: \(vaccination.notes)")
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 12) {
                    if !vaccination.isCompleted {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Text("Отметить как выполненную")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            // Здесь можно добавить логику для изменения статуса
                        }) {
                            Text("Изменить информацию")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Детали прививки")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            VaccinationCompletionSheet(
                viewModel: viewModel,
                vaccination: vaccination,
                isPresented: $showingEditSheet
            )
        }
    }
}

struct VaccinationCompletionSheet: View {
    @ObservedObject var viewModel: VaccinationViewModel
    let vaccination: Vaccination
    @Binding var isPresented: Bool
    
    @State private var completedDate = Date()
    @State private var notes = ""
    @State private var vaccineType = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дата выполнения")) {
                    DatePicker("Дата", selection: $completedDate, displayedComponents: .date)
                }
                
                Section(header: Text("Тип вакцины")) {
                    TextField("Название вакцины", text: $vaccineType)
                }
                
                Section(header: Text("Заметки")) {
                    TextField("Дополнительная информация", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Отметить выполнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.markVaccinationAsCompleted(
                            vaccination,
                            date: completedDate,
                            notes: notes,
                            vaccineType: vaccineType
                        )
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        VaccinationDetailView(
            viewModel: VaccinationViewModel(),
            vaccination: Vaccination(
                name: "БЦЖ",
                description: "Вакцина против туберкулёза",
                ageInMonths: 0,
                isRequired: true
            )
        )
    }
}