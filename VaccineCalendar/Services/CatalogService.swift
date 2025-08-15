import Foundation

enum CatalogError: Error {
    case notFound
    case decodeFailed
}

final class CatalogService {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    func loadCatalog(for countryCode: String) throws -> VaccineCatalog {
        let normalized = countryCode.uppercased()
        // Try direct lookup in subdirectory "Catalogs"
        if let url = Bundle.main.url(forResource: normalized, withExtension: "json", subdirectory: "Catalogs") {
            let data = try Data(contentsOf: url)
            do {
                return try decoder.decode(VaccineCatalog.self, from: data)
            } catch {
                throw CatalogError.decodeFailed
            }
        }
        // Fallback: search within the subdirectory
        if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Catalogs") {
            if let match = urls.first(where: { $0.lastPathComponent == "\(normalized).json" }) {
                let data = try Data(contentsOf: match)
                do {
                    return try decoder.decode(VaccineCatalog.self, from: data)
                } catch {
                    throw CatalogError.decodeFailed
                }
            }
        }
        throw CatalogError.notFound
    }
}