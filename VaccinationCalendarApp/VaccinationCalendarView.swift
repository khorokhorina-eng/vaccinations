import SwiftUI

struct VaccinationCalendarView: View {
    @ObservedObject var vaccinationManager: VaccinationManager
    @State private var selectedTab = 0
    @State private var showingVaccinationDetail = false
    @State private var selectedVaccination: Vaccination?
    @State private var showingAddOptional = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with child info
                if let child = vaccinationManager.appData.child {
                    HeaderView(child: child, vaccinationManager: vaccinationManager)
                }
                
                // Tab selector
                TabSelector(selectedTab: $selectedTab)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Required Vaccinations
                    VaccinationListView(
                        vaccinations: vaccinationManager.requiredVaccinations,
                        vaccinationManager: vaccinationManager,
                        selectedVaccination: $selectedVaccination,
                        showingDetail: $showingVaccinationDetail,
                        title: "Обязательные прививки"
                    )
                    .tag(0)
                    
                    // Optional Vaccinations
                    OptionalVaccinationsView(
                        vaccinationManager: vaccinationManager,
                        selectedVaccination: $selectedVaccination,
                        showingDetail: $showingVaccinationDetail,
                        showingAddOptional: $showingAddOptional
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingVaccinationDetail) {
            if let vaccination = selectedVaccination {
                VaccinationDetailView(
                    vaccination: vaccination,
                    vaccinationManager: vaccinationManager
                )
            }
        }
        .sheet(isPresented: $showingAddOptional) {
            AddOptionalVaccinationView(vaccinationManager: vaccinationManager)
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    let child: Child
    let vaccinationManager: VaccinationManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(child.country.name) • \(ageText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ProgressRing(progress: progressValue)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private var ageText: String {
        let ageInMonths = vaccinationManager.getChildAgeInMonths()
        if ageInMonths < 12 {
            return "\(ageInMonths) мес."
        } else {
            let years = ageInMonths / 12
            let months = ageInMonths % 12
            if months == 0 {
                return "\(years) год(а)"
            } else {
                return "\(years) год(а) \(months) мес."
            }
        }
    }
    
    private var progressValue: Double {
        let progress = vaccinationManager.getVaccinationProgress()
        return progress.total > 0 ? Double(progress.completed) / Double(progress.total) : 0
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Tab Selector

struct TabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "Обязательные", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Дополнительные", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
        }
    }
}

// MARK: - Vaccination List View

struct VaccinationListView: View {
    let vaccinations: [Vaccination]
    let vaccinationManager: VaccinationManager
    @Binding var selectedVaccination: Vaccination?
    @Binding var showingDetail: Bool
    let title: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedVaccinations, id: \.id) { vaccination in
                    VaccinationCard(
                        vaccination: vaccination,
                        vaccinationManager: vaccinationManager
                    )
                    .onTapGesture {
                        selectedVaccination = vaccination
                        showingDetail = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var sortedVaccinations: [Vaccination] {
        vaccinations.sorted { $0.ageInMonths < $1.ageInMonths }
    }
}

// MARK: - Optional Vaccinations View

struct OptionalVaccinationsView: View {
    let vaccinationManager: VaccinationManager
    @Binding var selectedVaccination: Vaccination?
    @Binding var showingDetail: Bool
    @Binding var showingAddOptional: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Add button
            Button(action: {
                showingAddOptional = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Добавить дополнительную прививку")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Added optional vaccinations
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(sortedOptionalVaccinations, id: \.id) { vaccination in
                        VaccinationCard(
                            vaccination: vaccination,
                            vaccinationManager: vaccinationManager
                        )
                        .onTapGesture {
                            selectedVaccination = vaccination
                            showingDetail = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
    
    private var sortedOptionalVaccinations: [Vaccination] {
        vaccinationManager.addedOptionalVaccinations.sorted { $0.ageInMonths < $1.ageInMonths }
    }
}

// MARK: - Vaccination Card

struct VaccinationCard: View {
    let vaccination: Vaccination
    let vaccinationManager: VaccinationManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccination.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(vaccination.ageDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    statusIcon
                    statusText
                }
            }
            
            if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id),
               record.isCompleted {
                VStack(alignment: .leading, spacing: 4) {
                    if let completedDate = record.completedDate {
                        Text("Выполнено: \(completedDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if !record.notes.isEmpty {
                        Text("Заметка: \(record.notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let vaccineName = record.vaccineName, !vaccineName.isEmpty {
                        Text("Вакцина: \(vaccineName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
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
        .font(.title2)
    }
    
    private var statusText: some View {
        Group {
            if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id) {
                if record.isCompleted {
                    Text("Готово")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if vaccinationManager.isVaccinationOverdue(vaccination) {
                    Text("Просрочено")
                        .font(.caption)
                        .foregroundColor(.red)
                } else if vaccinationManager.isVaccinationDue(vaccination) {
                    Text("Пора")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Ожидание")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Text("Ожидание")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var borderColor: Color {
        if let record = vaccinationManager.getVaccinationRecord(for: vaccination.id) {
            if record.isCompleted {
                return .green.opacity(0.3)
            } else if vaccinationManager.isVaccinationOverdue(vaccination) {
                return .red.opacity(0.3)
            } else if vaccinationManager.isVaccinationDue(vaccination) {
                return .orange.opacity(0.3)
            }
        }
        return Color(.systemGray4)
    }
}

// MARK: - Add Optional Vaccination View

struct AddOptionalVaccinationView: View {
    let vaccinationManager: VaccinationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(vaccinationManager.availableOptionalVaccinations, id: \.id) { vaccination in
                Button(action: {
                    vaccinationManager.addOptionalVaccination(vaccinationId: vaccination.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vaccination.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(vaccination.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(vaccination.ageDescription)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Добавить прививку")
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

struct VaccinationCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        VaccinationCalendarView(vaccinationManager: VaccinationManager())
    }
}