import SwiftUI

struct VaccinationCalendarView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    @State private var showingAddVaccination = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок с информацией о ребёнке
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Привет, \(viewModel.child.name)!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Возраст: \(viewModel.child.age) лет, \(viewModel.child.ageInMonths % 12) месяцев")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Здесь можно добавить настройки профиля
                        }) {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Прогресс прививок
                    VStack(spacing: 8) {
                        HStack {
                            Text("Прогресс прививок")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(viewModel.progressPercentage * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: viewModel.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Сегментированный контроль
                Picker("", selection: $selectedTab) {
                    Text("Все").tag(0)
                    Text("Выполненные").tag(1)
                    Text("Предстоящие").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                // Содержимое в зависимости от выбранной вкладки
                TabView(selection: $selectedTab) {
                    // Все прививки
                    AllVaccinationsView(viewModel: viewModel)
                        .tag(0)
                    
                    // Выполненные прививки
                    CompletedVaccinationsView(viewModel: viewModel)
                        .tag(1)
                    
                    // Предстоящие прививки
                    UpcomingVaccinationsView(viewModel: viewModel)
                        .tag(2)
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
                AddCustomVaccinationSheet(viewModel: viewModel, isPresented: $showingAddVaccination)
            }
        }
    }
}

struct AllVaccinationsView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    
    var body: some View {
        List {
            if viewModel.vaccinationService.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if let error = viewModel.vaccinationService.error {
                HStack {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else {
                let vaccinations = viewModel.getVaccinationsForCurrentAge()
                
                if vaccinations.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "syringe")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Нет доступных прививок")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(vaccinations) { vaccination in
                        VaccinationRowView(vaccination: vaccination)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct CompletedVaccinationsView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    
    var body: some View {
        List {
            let completedVaccinations = viewModel.getVaccinationsForCurrentAge().filter { $0.isCompleted }
            
            if completedVaccinations.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Нет выполненных прививок")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else {
                ForEach(completedVaccinations) { vaccination in
                    VaccinationRowView(vaccination: vaccination)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct UpcomingVaccinationsView: View {
    @ObservedObject var viewModel: VaccinationViewModel
    
    var body: some View {
        List {
            let upcomingVaccinations = viewModel.getUpcomingVaccinations()
            let overdueVaccinations = viewModel.getOverdueVaccinations()
            
            if overdueVaccinations.isNotEmpty {
                Section("Просроченные") {
                    ForEach(overdueVaccinations) { vaccination in
                        VaccinationRowView(vaccination: vaccination)
                    }
                }
            }
            
            if upcomingVaccinations.isNotEmpty {
                Section("Предстоящие") {
                    ForEach(upcomingVaccinations) { vaccination in
                        VaccinationRowView(vaccination: vaccination)
                    }
                }
            }
            
            if upcomingVaccinations.isEmpty && overdueVaccinations.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Нет предстоящих прививок")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct VaccinationRowView: View {
    let vaccination: Vaccination
    
    var body: some View {
        NavigationLink(destination: VaccinationDetailView(viewModel: VaccinationViewModel(), vaccination: vaccination)) {
            HStack(spacing: 12) {
                // Иконка статуса
                Image(systemName: vaccination.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(vaccination.isCompleted ? .green : .gray)
                    .font(.title2)
                
                // Информация о прививке
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccination.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(vaccination.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("\(vaccination.ageInMonths) мес.")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        if vaccination.isRequired {
                            Text("Обязательная")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Индикаторы
                VStack(alignment: .trailing, spacing: 4) {
                    if vaccination.isOverdue {
                        Text("Просрочено")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if vaccination.isDueSoon {
                        Text("Скоро")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct AddCustomVaccinationSheet: View {
    @ObservedObject var viewModel: VaccinationViewModel
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var description = ""
    @State private var ageInMonths = 0
    @State private var isRequired = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название")) {
                    TextField("Название прививки", text: $name)
                }
                
                Section(header: Text("Описание")) {
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Возраст (месяцы)")) {
                    Stepper("\(ageInMonths) месяцев", value: $ageInMonths, in: 0...1200)
                }
                
                Section(header: Text("Тип")) {
                    Toggle("Обязательная прививка", isOn: $isRequired)
                }
            }
            .navigationTitle("Добавить прививку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        viewModel.addCustomVaccination(
                            name: name,
                            description: description,
                            ageInMonths: ageInMonths,
                            isRequired: isRequired
                        )
                        isPresented = false
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    VaccinationCalendarView(viewModel: VaccinationViewModel())
}