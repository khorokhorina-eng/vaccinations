import Foundation

enum ScheduleLoaderError: Error {
    case fileNotFound
    case decodingFailed
    case countryNotFound
}

final class ScheduleLoader {
    private let fileName = "vaccination_schedule"
    private let fileExtension = "json"

    func schedule(for country: String) throws -> CountrySchedule {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            throw ScheduleLoaderError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let allSchedules = try JSONDecoder().decode([String: CountrySchedule].self, from: data)
        guard let schedule = allSchedules[country] else {
            throw ScheduleLoaderError.countryNotFound
        }
        return schedule
    }

    /// List of all available countries from JSON
    func availableCountries() -> [String] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension),
              let data = try? Data(contentsOf: url),
              let allSchedules = try? JSONDecoder().decode([String: CountrySchedule].self, from: data) else {
            return []
        }
        return Array(allSchedules.keys).sorted()
    }
}