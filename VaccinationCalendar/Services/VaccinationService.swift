import Foundation

class VaccinationService: ObservableObject {
    @Published var vaccinations: [Vaccination] = []
    @Published var child: Child?
    
    private let userDefaults = UserDefaults.standard
    private let childKey = "savedChild"
    private let vaccinationsKey = "savedVaccinations"
    
    init() {
        loadChild()
        loadVaccinations()
        if vaccinations.isEmpty {
            loadDefaultVaccinations()
        }
    }
    
    // MARK: - Child Management
    
    func saveChild(_ child: Child) {
        self.child = child
        if let encoded = try? JSONEncoder().encode(child) {
            userDefaults.set(encoded, forKey: childKey)
        }
    }
    
    private func loadChild() {
        if let data = userDefaults.data(forKey: childKey),
           let decodedChild = try? JSONDecoder().decode(Child.self, from: data) {
            self.child = decodedChild
        }
    }
    
    // MARK: - Vaccination Management
    
    func saveVaccinations() {
        if let encoded = try? JSONEncoder().encode(vaccinations) {
            userDefaults.set(encoded, forKey: vaccinationsKey)
        }
    }
    
    private func loadVaccinations() {
        if let data = userDefaults.data(forKey: vaccinationsKey),
           let decodedVaccinations = try? JSONDecoder().decode([Vaccination].self, from: data) {
            self.vaccinations = decodedVaccinations
        }
    }
    
    func updateVaccination(_ vaccination: Vaccination) {
        if let index = vaccinations.firstIndex(where: { $0.id == vaccination.id }) {
            vaccinations[index] = vaccination
            saveVaccinations()
        }
    }
    
    func addCustomVaccination(_ vaccination: Vaccination) {
        vaccinations.append(vaccination)
        saveVaccinations()
    }
    
    // MARK: - Default Data
    
    private func loadDefaultVaccinations() {
        // Российский национальный календарь прививок
        let defaultVaccinations = [
            Vaccination(
                name: "Гепатит B",
                description: "Первая вакцинация против вирусного гепатита B",
                recommendedAge: AgeRange(fromAge: 0, toAge: 0),
                isRequired: true
            ),
            Vaccination(
                name: "БЦЖ",
                description: "Вакцинация против туберкулеза",
                recommendedAge: AgeRange(fromAge: 0, toAge: 0),
                isRequired: true
            ),
            Vaccination(
                name: "Гепатит B",
                description: "Вторая вакцинация против вирусного гепатита B",
                recommendedAge: AgeRange(fromAge: 1, toAge: 1),
                isRequired: true
            ),
            Vaccination(
                name: "Пневмококковая инфекция",
                description: "Первая вакцинация против пневмококковой инфекции",
                recommendedAge: AgeRange(fromAge: 2, toAge: 2),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, коклюш, столбняк",
                description: "Первая вакцинация против дифтерии, коклюша, столбняка",
                recommendedAge: AgeRange(fromAge: 3, toAge: 3),
                isRequired: true
            ),
            Vaccination(
                name: "Полиомиелит",
                description: "Первая вакцинация против полиомиелита",
                recommendedAge: AgeRange(fromAge: 3, toAge: 3),
                isRequired: true
            ),
            Vaccination(
                name: "Гемофильная инфекция",
                description: "Первая вакцинация против гемофильной инфекции",
                recommendedAge: AgeRange(fromAge: 3, toAge: 3),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, коклюш, столбняк",
                description: "Вторая вакцинация против дифтерии, коклюша, столбняка",
                recommendedAge: AgeRange(fromAge: 4, toAge: 4),
                isRequired: true
            ),
            Vaccination(
                name: "Полиомиелит",
                description: "Вторая вакцинация против полиомиелита",
                recommendedAge: AgeRange(fromAge: 4, toAge: 4),
                isRequired: true
            ),
            Vaccination(
                name: "Пневмококковая инфекция",
                description: "Вторая вакцинация против пневмококковой инфекции",
                recommendedAge: AgeRange(fromAge: 4, toAge: 4),
                isRequired: true
            ),
            Vaccination(
                name: "Гемофильная инфекция",
                description: "Вторая вакцинация против гемофильной инфекции",
                recommendedAge: AgeRange(fromAge: 4, toAge: 4),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, коклюш, столбняк",
                description: "Третья вакцинация против дифтерии, коклюша, столбняка",
                recommendedAge: AgeRange(fromAge: 6, toAge: 6),
                isRequired: true
            ),
            Vaccination(
                name: "Полиомиелит",
                description: "Третья вакцинация против полиомиелита",
                recommendedAge: AgeRange(fromAge: 6, toAge: 6),
                isRequired: true
            ),
            Vaccination(
                name: "Гемофильная инфекция",
                description: "Третья вакцинация против гемофильной инфекции",
                recommendedAge: AgeRange(fromAge: 6, toAge: 6),
                isRequired: true
            ),
            Vaccination(
                name: "Гепатит B",
                description: "Третья вакцинация против вирусного гепатита B",
                recommendedAge: AgeRange(fromAge: 6, toAge: 6),
                isRequired: true
            ),
            Vaccination(
                name: "Корь, краснуха, паротит",
                description: "Вакцинация против кори, краснухи и эпидемического паротита",
                recommendedAge: AgeRange(fromAge: 12, toAge: 12),
                isRequired: true
            ),
            Vaccination(
                name: "Пневмококковая инфекция",
                description: "Ревакцинация против пневмококковой инфекции",
                recommendedAge: AgeRange(fromAge: 15, toAge: 15),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, коклюш, столбняк",
                description: "Первая ревакцинация против дифтерии, коклюша, столбняка",
                recommendedAge: AgeRange(fromAge: 18, toAge: 18),
                isRequired: true
            ),
            Vaccination(
                name: "Полиомиелит",
                description: "Первая ревакцинация против полиомиелита",
                recommendedAge: AgeRange(fromAge: 18, toAge: 18),
                isRequired: true
            ),
            Vaccination(
                name: "Гемофильная инфекция",
                description: "Ревакцинация против гемофильной инфекции",
                recommendedAge: AgeRange(fromAge: 18, toAge: 18),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, коклюш, столбняк",
                description: "Вторая ревакцинация против дифтерии, коклюша, столбняка",
                recommendedAge: AgeRange(fromAge: 72, toAge: 72),
                isRequired: true
            ),
            Vaccination(
                name: "Полиомиелит",
                description: "Вторая ревакцинация против полиомиелита",
                recommendedAge: AgeRange(fromAge: 72, toAge: 72),
                isRequired: true
            ),
            Vaccination(
                name: "Корь, краснуха, паротит",
                description: "Ревакцинация против кори, краснухи и эпидемического паротита",
                recommendedAge: AgeRange(fromAge: 72, toAge: 72),
                isRequired: true
            ),
            Vaccination(
                name: "Дифтерия, столбняк",
                description: "Ревакцинация против дифтерии и столбняка",
                recommendedAge: AgeRange(fromAge: 168, toAge: 168),
                isRequired: true
            ),
            Vaccination(
                name: "Корь",
                description: "Вакцинация против кори (взрослые)",
                recommendedAge: AgeRange(fromAge: 216, toAge: 216),
                isRequired: false
            ),
            Vaccination(
                name: "Грипп",
                description: "Ежегодная вакцинация против гриппа",
                recommendedAge: AgeRange(fromAge: 72, toAge: 1200),
                isRequired: false
            )
        ]
        
        self.vaccinations = defaultVaccinations
        saveVaccinations()
    }
    
    // MARK: - Helper Methods
    
    func getVaccinationsForAge(_ ageInMonths: Int) -> [Vaccination] {
        return vaccinations.filter { vaccination in
            ageInMonths >= vaccination.recommendedAge.fromAge && 
            ageInMonths <= vaccination.recommendedAge.toAge
        }
    }
    
    func getUpcomingVaccinations(for ageInMonths: Int) -> [Vaccination] {
        return vaccinations.filter { vaccination in
            ageInMonths < vaccination.recommendedAge.fromAge && 
            !vaccination.isCompleted
        }.sorted { $0.recommendedAge.fromAge < $1.recommendedAge.fromAge }
    }
    
    func getCompletedVaccinations() -> [Vaccination] {
        return vaccinations.filter { $0.isCompleted }
    }
    
    func getPendingVaccinations() -> [Vaccination] {
        return vaccinations.filter { !$0.isCompleted }
    }
}