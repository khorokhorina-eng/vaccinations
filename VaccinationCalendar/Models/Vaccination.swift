import Foundation

struct Vaccination: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var ageInMonths: Int
    var isRequired: Bool
    var isCompleted: Bool
    var completedDate: Date?
    var notes: String
    var vaccineType: String
    
    init(name: String, description: String, ageInMonths: Int, isRequired: Bool, isCompleted: Bool = false, completedDate: Date? = nil, notes: String = "", vaccineType: String = "") {
        self.name = name
        self.description = description
        self.ageInMonths = ageInMonths
        self.isRequired = isRequired
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.notes = notes
        self.vaccineType = vaccineType
    }
    
    var isOverdue: Bool {
        guard !isCompleted else { return false }
        let currentAgeInMonths = Calendar.current.dateComponents([.month], from: Date().addingTimeInterval(-TimeInterval(ageInMonths * 30 * 24 * 60 * 60)), to: Date()).month ?? 0
        return currentAgeInMonths > 0
    }
    
    var isDueSoon: Bool {
        guard !isCompleted else { return false }
        let currentAgeInMonths = Calendar.current.dateComponents([.month], from: Date().addingTimeInterval(-TimeInterval(ageInMonths * 30 * 24 * 60 * 60)), to: Date()).month ?? 0
        return currentAgeInMonths >= -1 && currentAgeInMonths <= 0
    }
}

struct VaccinationSchedule: Codable {
    let country: String
    let vaccinations: [Vaccination]
}