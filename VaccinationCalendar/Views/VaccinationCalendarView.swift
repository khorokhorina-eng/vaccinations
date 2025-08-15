import SwiftUI

struct VaccinationCalendarView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    @State private var selectedTab = 0
    @State private var showingAddVaccination = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with child info
                if let child = viewModel.child {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(child.name.isEmpty ? "Ребёнок" : child.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("\(child.age) лет, \(child.ageInMonths % 12) мес.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(child.country)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Родился \(child.birthDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
                
                // Tab Picker
                Picker("Вкладки", selection: $selectedTab) {
                    Text("Текущие").tag(0)
                    Text("Предстоящие").tag(1)
                    Text("Выполненные").tag(2)
                    Text("Все").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Current Age Vaccinations
                    VaccinationListView(
                        viewModel: viewModel,
                        vaccinations: viewModel.currentAgeVaccinations,
                        title: "Прививки для текущего возраста"
                    )
                    .tag(0)
                    
                    // Upcoming Vaccinations
                    VaccinationListView(
                        viewModel: viewModel,
                        vaccinations: viewModel.upcomingVaccinations,
                        title: "Предстоящие прививки"
                    )
                    .tag(1)
                    
                    // Completed Vaccinations
                    VaccinationListView(
                        viewModel: viewModel,
                        vaccinations: viewModel.completedVaccinations,
                        title: "Выполненные прививки"
                    )
                    .tag(2)
                    
                    // All Vaccinations
                    VaccinationListView(
                        viewModel: viewModel,
                        vaccinations: viewModel.vaccinations,
                        title: "Все прививки"
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Календарь прививок")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddVaccination = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddVaccination) {
                AddVaccinationView(viewModel: viewModel)
            }
        }
    }
}

struct VaccinationListView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    let vaccinations: [Vaccination]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if vaccinations.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Нет прививок для отображения")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vaccinations) { vaccination in
                            VaccinationRowView(viewModel: viewModel, vaccination: vaccination)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct VaccinationRowView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    let vaccination: Vaccination
    
    var body: some View {
        NavigationLink(destination: VaccinationDetailView(viewModel: viewModel, vaccination: vaccination)) {
            HStack(spacing: 16) {
                // Status indicator
                Circle()
                    .fill(viewModel.getVaccinationStatus(for: vaccination).color)
                    .frame(width: 12, height: 12)
                
                // Vaccination info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vaccination.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if vaccination.isRequired {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    
                    Text(vaccination.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label(vaccination.recommendedAge.displayText, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text(viewModel.getVaccinationStatus(for: vaccination).text)
                            .font(.caption)
                            .foregroundColor(viewModel.getVaccinationStatus(for: vaccination).color)
                    }
                }
                
                // Completion status
                Button(action: {
                    viewModel.toggleVaccinationCompletion(vaccination)
                }) {
                    Image(systemName: vaccination.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(vaccination.isCompleted ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddVaccinationView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var ageInMonths = 0
    @State private var isRequired = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о прививке") {
                    TextField("Название", text: $name)
                    TextField("Описание", text: $description)
                    
                    Stepper("Возраст: \(ageInMonths) мес.", value: $ageInMonths, in: 0...1200)
                    
                    Toggle("Обязательная прививка", isOn: $isRequired)
                }
                
                Section {
                    Button("Добавить") {
                        viewModel.addCustomVaccination(
                            name: name,
                            description: description,
                            ageInMonths: ageInMonths,
                            isRequired: isRequired
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
            .navigationTitle("Добавить прививку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VaccinationCalendarView(viewModel: VaccinationViewModel())
}