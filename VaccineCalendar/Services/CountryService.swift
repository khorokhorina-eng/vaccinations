import Foundation

struct Country: Identifiable, Equatable {
    var id: String { code }
    let code: String
    let name: String
}

enum CountryService {
    static let supported: [Country] = [
        Country(code: "RU", name: "Россия"),
        Country(code: "US", name: "США")
    ]
}