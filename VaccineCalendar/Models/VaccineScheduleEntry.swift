import Foundation

struct VaccineScheduleEntry: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let ageOffset: AgeOffset
}