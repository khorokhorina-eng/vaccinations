import Foundation
import SwiftUI

class VaccinationViewModel: ObservableObject {
    @Published var child: Child
    @Published var vaccinationService = VaccinationService()
    @Published var showingAddVaccination = false
    @Published var selectedVaccination: Vaccination?
    
    private let userDefaults = UserDefaults.standard
    private let childKey = "savedChild"
    
    init() {
        // Загружаем сохранённые данные о ребёнке
        if let data = userDefaults.data(forKey: childKey),
           let savedChild = try? JSONDecoder().decode(Child.self, from: data) {
            self.child = savedChild
        } else {
            self.child = Child()
        }
        
        // Если ребёнок уже настроен, загружаем расписание прививок
        if child.isOnboarded {
            vaccinationService.loadVaccinationSchedule(for: child.country)
        }
    }
    
    func saveChild() {
        child.isOnboarded = true
        if let encoded = try? JSONEncoder().encode(child) {
            userDefaults.set(encoded, forKey: childKey)
        }
        
        // Загружаем расписание прививок для страны
        vaccinationService.loadVaccinationSchedule(for: child.country)
    }
    
    func updateChild(name: String, birthDate: Date, country: String) {
        child.name = name
        child.birthDate = birthDate
        child.country = country
        saveChild()
    }
    
    func getVaccinationsForCurrentAge() -> [Vaccination] {
        return vaccinationService.getVaccinationsForAge(child.ageInMonths)
    }
    
    func getUpcomingVaccinations() -> [Vaccination] {
        return vaccinationService.getUpcomingVaccinations(currentAgeInMonths: child.ageInMonths)
    }
    
    func getOverdueVaccinations() -> [Vaccination] {
        return vaccinationService.getOverdueVaccinations(currentAgeInMonths: child.ageInMonths)
    }
    
    func markVaccinationAsCompleted(_ vaccination: Vaccination, date: Date, notes: String, vaccineType: String) {
        _ = vaccinationService.markVaccinationAsCompleted(vaccination, date: date, notes: notes, vaccineType: vaccineType)
    }
    
    func addCustomVaccination(name: String, description: String, ageInMonths: Int, isRequired: Bool) {
        let customVaccination = Vaccination(
            name: name,
            description: description,
            ageInMonths: ageInMonths,
            isRequired: isRequired
        )
        vaccinationService.addCustomVaccination(customVaccination)
    }
    
    var progressPercentage: Double {
        let completed = getVaccinationsForCurrentAge().filter { $0.isCompleted }.count
        let total = getVaccinationsForCurrentAge().count
        return total > 0 ? Double(completed) / Double(total) : 0.0
    }
    
    var nextVaccination: Vaccination? {
        return getUpcomingVaccinations().first
    }
    
    var overdueCount: Int {
        return getOverdueVaccinations().count
    }
}