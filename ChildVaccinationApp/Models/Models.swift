import Foundation

struct Vaccination: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let ageMonths: Int // due age in months since birth
    let description: String
    let isMandatory: Bool
}

struct VaccinationRecord: Identifiable, Codable {
    let id: UUID
    let vaccination: Vaccination
    let dueDate: Date
    var isDone: Bool
    var note: String

    init(vaccination: Vaccination, dueDate: Date, isDone: Bool, note: String) {
        self.id = UUID()
        self.vaccination = vaccination
        self.dueDate = dueDate
        self.isDone = isDone
        self.note = note
    }
}

struct CountrySchedule: Codable {
    var mandatory: [Vaccination]
    var optional: [Vaccination]
}