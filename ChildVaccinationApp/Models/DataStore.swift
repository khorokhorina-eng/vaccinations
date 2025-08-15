import Foundation
import SwiftUI

final class DataStore: ObservableObject {
    // MARK: - Published Properties
    @Published var birthDate: Date?
    @Published var country: String?
    @Published var records: [VaccinationRecord] = []

    // MARK: - Constants
    private enum Keys {
        static let birthDate = "birthDate"
        static let country = "country"
        static let records = "records"
    }

    // MARK: - Helpers
    var isFirstLaunch: Bool {
        return birthDate == nil || country == nil
    }

    private let defaults: UserDefaults
    private let scheduleLoader: ScheduleLoader

    init(defaults: UserDefaults = .standard, scheduleLoader: ScheduleLoader = ScheduleLoader()) {
        self.defaults = defaults
        self.scheduleLoader = scheduleLoader
    }

    // MARK: - Persistence
    func load() {
        if let birthTimestamp = defaults.value(forKey: Keys.birthDate) as? TimeInterval {
            birthDate = Date(timeIntervalSince1970: birthTimestamp)
        }
        country = defaults.string(forKey: Keys.country)
        if let recordData = defaults.data(forKey: Keys.records) {
            if let decoded = try? JSONDecoder().decode([VaccinationRecord].self, from: recordData) {
                records = decoded
            }
        }
    }

    private func save() {
        if let birthDate = birthDate {
            defaults.set(birthDate.timeIntervalSince1970, forKey: Keys.birthDate)
        }
        if let country = country {
            defaults.set(country, forKey: Keys.country)
        }
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: Keys.records)
        }
    }

    // MARK: - Public Methods
    func setupChildProfile(birthDate: Date, country: String) {
        self.birthDate = birthDate
        self.country = country
        generateInitialSchedule()
        save()
    }

    func toggleDone(for recordID: UUID) {
        guard let idx = records.firstIndex(where: { $0.id == recordID }) else { return }
        records[idx].isDone.toggle()
        save()
    }

    func updateNote(for recordID: UUID, note: String) {
        guard let idx = records.firstIndex(where: { $0.id == recordID }) else { return }
        records[idx].note = note
        save()
    }

    func addOptionalVaccination(_ vaccination: Vaccination) {
        guard let birthDate = birthDate else { return }
        let dueDate = Calendar.current.date(byAdding: .month, value: vaccination.ageMonths, to: birthDate) ?? birthDate
        let record = VaccinationRecord(vaccination: vaccination, dueDate: dueDate, isDone: false, note: "")
        records.append(record)
        save()
    }

    func scheduleForCurrentCountry() -> CountrySchedule? {
        guard let country = country else { return nil }
        return try? scheduleLoader.schedule(for: country)
    }

    // MARK: - Private
    private func generateInitialSchedule() {
        guard let birthDate = birthDate, let country = country else { return }
        do {
            let schedule = try scheduleLoader.schedule(for: country)
            records = schedule.mandatory.map { vaccination in
                let dueDate = Calendar.current.date(byAdding: .month, value: vaccination.ageMonths, to: birthDate) ?? birthDate
                return VaccinationRecord(vaccination: vaccination, dueDate: dueDate, isDone: false, note: "")
            }
            save()
        } catch {
            print("Failed to generate schedule: \(error)")
        }
    }

    // Helper to expose countries list
    func availableCountries() -> [String] {
        scheduleLoader.availableCountries()
    }

    // MARK: - Preview Helper
    static var preview: DataStore {
        let store = DataStore(defaults: .standard)
        store.birthDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        store.country = "USA"
        store.records = [
            VaccinationRecord(vaccination: Vaccination(id: UUID(), name: "Hepatitis B", ageMonths: 0, description: "Test", isMandatory: true), dueDate: Date(), isDone: false, note: "")
        ]
        return store
    }
}