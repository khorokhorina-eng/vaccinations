import Foundation

struct Vaccination: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var recommendedAge: AgeRange
    var isRequired: Bool
    var isCompleted: Bool
    var completedDate: Date?
    var notes: String
    var vaccineType: String
    
    init(name: String, description: String, recommendedAge: AgeRange, isRequired: Bool = true, isCompleted: Bool = false, completedDate: Date? = nil, notes: String = "", vaccineType: String = "") {
        self.name = name
        self.description = description
        self.recommendedAge = recommendedAge
        self.isRequired = isRequired
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.notes = notes
        self.vaccineType = vaccineType
    }
}

struct AgeRange: Codable {
    var fromAge: Int // в месяцах
    var toAge: Int // в месяцах
    
    var displayText: String {
        if fromAge == 0 {
            return "При рождении"
        } else if fromAge < 12 {
            return "\(fromAge) мес."
        } else if fromAge == 12 {
            return "1 год"
        } else {
            let fromYears = fromAge / 12
            let fromMonths = fromAge % 12
            if fromMonths == 0 {
                return "\(fromYears) лет"
            } else {
                return "\(fromYears) лет \(fromMonths) мес."
            }
        }
    }
    
    init(fromAge: Int, toAge: Int) {
        self.fromAge = fromAge
        self.toAge = toAge
    }
}