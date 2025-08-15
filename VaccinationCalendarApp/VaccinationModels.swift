import Foundation

// MARK: - Country
struct Country: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let code: String
}

// MARK: - Child
struct Child: Codable {
    let id: UUID
    var name: String
    var birthDate: Date
    var country: Country
    var createdAt: Date
    
    init(name: String, birthDate: Date, country: Country) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.country = country
        self.createdAt = Date()
    }
}

// MARK: - Vaccination
struct Vaccination: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let ageInMonths: Int
    let isRequired: Bool
    let countryCode: String
    
    var ageDescription: String {
        if ageInMonths == 0 {
            return "При рождении"
        } else if ageInMonths < 12 {
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
}

// MARK: - Vaccination Record
struct VaccinationRecord: Codable, Identifiable {
    let id: UUID
    let vaccinationId: String
    let childId: UUID
    var isCompleted: Bool
    var completedDate: Date?
    var notes: String
    var vaccineName: String?
    
    init(vaccinationId: String, childId: UUID) {
        self.id = UUID()
        self.vaccinationId = vaccinationId
        self.childId = childId
        self.isCompleted = false
        self.completedDate = nil
        self.notes = ""
        self.vaccineName = nil
    }
}

// MARK: - Vaccination Schedule
struct VaccinationSchedule: Codable {
    let countryCode: String
    let countryName: String
    let vaccinations: [Vaccination]
}

// MARK: - App Data
struct AppData: Codable {
    var child: Child?
    var isOnboardingCompleted: Bool
    var vaccinationRecords: [VaccinationRecord]
    
    init() {
        self.child = nil
        self.isOnboardingCompleted = false
        self.vaccinationRecords = []
    }
}

// MARK: - Available Countries
extension Country {
    static let availableCountries = [
        Country(id: "RU", name: "Россия", code: "RU"),
        Country(id: "US", name: "США", code: "US"),
        Country(id: "DE", name: "Германия", code: "DE"),
        Country(id: "FR", name: "Франция", code: "FR"),
        Country(id: "GB", name: "Великобритания", code: "GB")
    ]
}