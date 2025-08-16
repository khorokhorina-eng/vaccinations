import Foundation
import SwiftUI

@MainActor
class VaccinationManager: ObservableObject {
    @Published var appData = AppData()
    @Published var availableSchedules: [VaccinationSchedule] = []
    @Published var currentSchedule: VaccinationSchedule?
    
    private let userDefaults = UserDefaults.standard
    private let appDataKey = "VaccinationAppData"
    
    init() {
        loadAppData()
        loadVaccinationSchedules()
        updateCurrentSchedule()
    }
    
    // MARK: - Data Persistence
    
    private func loadAppData() {
        if let data = userDefaults.data(forKey: appDataKey),
           let decoded = try? JSONDecoder().decode(AppData.self, from: data) {
            appData = decoded
        }
    }
    
    func saveAppData() {
        if let encoded = try? JSONEncoder().encode(appData) {
            userDefaults.set(encoded, forKey: appDataKey)
        }
    }
    
    // MARK: - Vaccination Schedules
    
    private func loadVaccinationSchedules() {
        guard let url = Bundle.main.url(forResource: "vaccination_schedules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load vaccination schedules")
            return
        }
        
        do {
            let schedulesData = try JSONDecoder().decode(SchedulesData.self, from: data)
            availableSchedules = schedulesData.schedules
            updateCurrentSchedule()
        } catch {
            print("Error decoding vaccination schedules: \(error)")
        }
    }
    
    private func updateCurrentSchedule() {
        guard let child = appData.child else { return }
        currentSchedule = availableSchedules.first { $0.countryCode == child.country.code }
    }
    
    // MARK: - Child Management
    
    func setChild(name: String, birthDate: Date, country: Country) {
        let child = Child(name: name, birthDate: birthDate, country: country)
        appData.child = child
        appData.isOnboardingCompleted = true
        updateCurrentSchedule()
        initializeVaccinationRecords()
        saveAppData()
    }
    
    func updateChild(_ child: Child) {
        appData.child = child
        updateCurrentSchedule()
        saveAppData()
    }
    
    // MARK: - Vaccination Records
    
    private func initializeVaccinationRecords() {
        guard let child = appData.child,
              let schedule = currentSchedule else { return }
        
        // Create records for all required vaccinations
        for vaccination in schedule.vaccinations where vaccination.isRequired {
            if !appData.vaccinationRecords.contains(where: { $0.vaccinationId == vaccination.id && $0.childId == child.id }) {
                let record = VaccinationRecord(vaccinationId: vaccination.id, childId: child.id)
                appData.vaccinationRecords.append(record)
            }
        }
        saveAppData()
    }
    
    func getVaccinationRecord(for vaccinationId: String) -> VaccinationRecord? {
        guard let child = appData.child else { return nil }
        return appData.vaccinationRecords.first { $0.vaccinationId == vaccinationId && $0.childId == child.id }
    }
    
    func updateVaccinationRecord(_ record: VaccinationRecord) {
        if let index = appData.vaccinationRecords.firstIndex(where: { $0.id == record.id }) {
            appData.vaccinationRecords[index] = record
            saveAppData()
        }
    }
    
    func markVaccinationCompleted(vaccinationId: String, date: Date, notes: String = "", vaccineName: String? = nil) {
        guard let child = appData.child else { return }
        
        if var record = getVaccinationRecord(for: vaccinationId) {
            record.isCompleted = true
            record.completedDate = date
            record.notes = notes
            record.vaccineName = vaccineName
            updateVaccinationRecord(record)
        } else {
            var newRecord = VaccinationRecord(vaccinationId: vaccinationId, childId: child.id)
            newRecord.isCompleted = true
            newRecord.completedDate = date
            newRecord.notes = notes
            newRecord.vaccineName = vaccineName
            appData.vaccinationRecords.append(newRecord)
            saveAppData()
        }
    }
    
    func markVaccinationIncomplete(vaccinationId: String) {
        if var record = getVaccinationRecord(for: vaccinationId) {
            record.isCompleted = false
            record.completedDate = nil
            updateVaccinationRecord(record)
        }
    }
    
    func addOptionalVaccination(vaccinationId: String) {
        guard let child = appData.child,
              let vaccination = currentSchedule?.vaccinations.first(where: { $0.id == vaccinationId }),
              !vaccination.isRequired else { return }
        
        if !appData.vaccinationRecords.contains(where: { $0.vaccinationId == vaccinationId && $0.childId == child.id }) {
            let record = VaccinationRecord(vaccinationId: vaccinationId, childId: child.id)
            appData.vaccinationRecords.append(record)
            saveAppData()
        }
    }
    
    // MARK: - Computed Properties
    
    var requiredVaccinations: [Vaccination] {
        currentSchedule?.vaccinations.filter { $0.isRequired } ?? []
    }
    
    var optionalVaccinations: [Vaccination] {
        currentSchedule?.vaccinations.filter { !$0.isRequired } ?? []
    }
    
    var addedOptionalVaccinations: [Vaccination] {
        guard let child = appData.child else { return [] }
        let addedOptionalIds = appData.vaccinationRecords
            .filter { $0.childId == child.id }
            .map { $0.vaccinationId }
        
        return optionalVaccinations.filter { addedOptionalIds.contains($0.id) }
    }
    
    var availableOptionalVaccinations: [Vaccination] {
        guard let child = appData.child else { return [] }
        let addedOptionalIds = appData.vaccinationRecords
            .filter { $0.childId == child.id }
            .map { $0.vaccinationId }
        
        return optionalVaccinations.filter { !addedOptionalIds.contains($0.id) }
    }
    
    func getVaccinationProgress() -> (completed: Int, total: Int) {
        guard let child = appData.child else { return (0, 0) }
        
        let relevantRecords = appData.vaccinationRecords.filter { $0.childId == child.id }
        let completed = relevantRecords.filter { $0.isCompleted }.count
        let total = relevantRecords.count
        
        return (completed, total)
    }
    
    // MARK: - Age Calculations
    
    func getChildAgeInMonths() -> Int {
        guard let child = appData.child else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: child.birthDate, to: Date())
        return components.month ?? 0
    }
    
    func isVaccinationDue(_ vaccination: Vaccination) -> Bool {
        let childAgeInMonths = getChildAgeInMonths()
        return childAgeInMonths >= vaccination.ageInMonths
    }
    
    func isVaccinationOverdue(_ vaccination: Vaccination) -> Bool {
        let childAgeInMonths = getChildAgeInMonths()
        return childAgeInMonths > vaccination.ageInMonths + 2 // Consider overdue after 2 months
    }
    
    // MARK: - Reset Data
    
    func resetAllData() {
        appData = AppData()
        userDefaults.removeObject(forKey: appDataKey)
    }
}

// MARK: - Supporting Types

private struct SchedulesData: Codable {
    let schedules: [VaccinationSchedule]
}