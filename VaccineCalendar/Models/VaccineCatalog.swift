import Foundation

struct VaccineCatalog: Codable, Equatable {
    let country: String
    let mandatory: [VaccineScheduleEntry]
    let recommended: [VaccineScheduleEntry]
}