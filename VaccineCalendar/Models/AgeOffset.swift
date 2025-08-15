import Foundation

struct AgeOffset: Codable, Equatable {
    var days: Int?
    var months: Int?
    var years: Int?

    func apply(to base: Date, using calendar: Calendar = .current) -> Date {
        var date = base
        if let years = years, years != 0 {
            date = calendar.date(byAdding: .year, value: years, to: date) ?? date
        }
        if let months = months, months != 0 {
            date = calendar.date(byAdding: .month, value: months, to: date) ?? date
        }
        if let days = days, days != 0 {
            date = calendar.date(byAdding: .day, value: days, to: date) ?? date
        }
        return date
    }
}