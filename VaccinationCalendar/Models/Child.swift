import Foundation

struct Child: Codable, Identifiable {
    let id = UUID()
    var name: String
    var birthDate: Date
    var country: String
    var isOnboarded: Bool
    
    init(name: String = "", birthDate: Date = Date(), country: String = "", isOnboarded: Bool = false) {
        self.name = name
        self.birthDate = birthDate
        self.country = country
        self.isOnboarded = isOnboarded
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
    }
}