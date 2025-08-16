import Foundation

enum LocalStore {
    private static let profileKey = "child_profile"
    private static let includedOptionalKey = "optional_included_ids"
    private static let completionStatusKey = "completion_status"
    private static let notesKey = "vaccine_notes"

    static func saveProfile(_ profile: ChildProfile) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    static func loadProfile() -> ChildProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(ChildProfile.self, from: data)
    }

    static func clearProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }

    static func saveIncludedOptionalIds(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: includedOptionalKey)
    }

    static func loadIncludedOptionalIds() -> [String] {
        (UserDefaults.standard.array(forKey: includedOptionalKey) as? [String]) ?? []
    }

    static func saveCompletionStatus(_ status: [String: Bool]) {
        UserDefaults.standard.set(status, forKey: completionStatusKey)
    }

    static func loadCompletionStatus() -> [String: Bool] {
        (UserDefaults.standard.dictionary(forKey: completionStatusKey) as? [String: Bool]) ?? [:]
    }

    static func saveNotes(_ notes: [String: String]) {
        UserDefaults.standard.set(notes, forKey: notesKey)
    }

    static func loadNotes() -> [String: String] {
        (UserDefaults.standard.dictionary(forKey: notesKey) as? [String: String]) ?? [:]
    }
}