import Foundation
import Combine

final class AppStore: ObservableObject {
    @Published var profile: ChildProfile? {
        didSet { persistProfile() }
    }

    @Published private(set) var catalog: VaccineCatalog?
    @Published var includedOptionalIds: Set<String> = [] {
        didSet { LocalStore.saveIncludedOptionalIds(Array(includedOptionalIds)) }
    }
    @Published var completionStatus: [String: Bool] = [:] {
        didSet { LocalStore.saveCompletionStatus(completionStatus) }
    }
    @Published var notes: [String: String] = [:] {
        didSet { LocalStore.saveNotes(notes) }
    }

    private let catalogService = CatalogService()

    init() {
        self.profile = LocalStore.loadProfile()
        self.includedOptionalIds = Set(LocalStore.loadIncludedOptionalIds())
        self.completionStatus = LocalStore.loadCompletionStatus()
        self.notes = LocalStore.loadNotes()

        if let existingProfile = profile {
            loadCatalog(for: existingProfile.countryCode)
        }
    }

    func setProfile(dateOfBirth: Date, countryCode: String) {
        self.profile = ChildProfile(dateOfBirth: dateOfBirth, countryCode: countryCode)
        self.includedOptionalIds = []
        self.completionStatus = [:]
        self.notes = [:]
        loadCatalog(for: countryCode)
    }

    func loadCatalog(for countryCode: String) {
        do {
            self.catalog = try catalogService.loadCatalog(for: countryCode)
        } catch {
            // Fallback to RU if available
            if countryCode != "RU", let fallback = try? catalogService.loadCatalog(for: "RU") {
                self.catalog = fallback
            } else {
                self.catalog = nil
            }
        }
    }

    func dueDate(for entry: VaccineScheduleEntry) -> Date? {
        guard let profile = profile else { return nil }
        return entry.ageOffset.apply(to: profile.dateOfBirth)
    }

    func isCompleted(_ id: String) -> Bool {
        completionStatus[id] ?? false
    }

    func toggleCompleted(_ id: String) {
        let newValue = !(completionStatus[id] ?? false)
        completionStatus[id] = newValue
    }

    func note(for id: String) -> String {
        notes[id] ?? ""
    }

    func setNote(_ note: String, for id: String) {
        var trimmed = note
        if trimmed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes.removeValue(forKey: id)
        } else {
            notes[id] = trimmed
        }
    }

    func isOptionalIncluded(_ id: String) -> Bool {
        includedOptionalIds.contains(id)
    }

    func addOptional(_ id: String) {
        includedOptionalIds.insert(id)
    }

    func removeOptional(_ id: String) {
        includedOptionalIds.remove(id)
    }

    var mandatoryEntries: [VaccineScheduleEntry] {
        catalog?.mandatory.sorted(by: { (dueDate(for: $0) ?? .distantPast) < (dueDate(for: $1) ?? .distantPast) }) ?? []
    }

    var includedOptionalEntries: [VaccineScheduleEntry] {
        guard let recommended = catalog?.recommended else { return [] }
        return recommended
            .filter { includedOptionalIds.contains($0.id) }
            .sorted(by: { (dueDate(for: $0) ?? .distantPast) < (dueDate(for: $1) ?? .distantPast) })
    }

    var availableOptionalEntries: [VaccineScheduleEntry] {
        guard let recommended = catalog?.recommended else { return [] }
        return recommended.filter { !includedOptionalIds.contains($0.id) }
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
    }

    private func persistProfile() {
        if let profile = profile {
            LocalStore.saveProfile(profile)
        } else {
            LocalStore.clearProfile()
        }
    }
}