import Foundation

class VaccinationService: ObservableObject {
    @Published var vaccinationSchedule: VaccinationSchedule?
    @Published var isLoading = false
    @Published var error: String?
    
    func loadVaccinationSchedule(for country: String) {
        isLoading = true
        error = nil
        
        // Загружаем тестовые данные из JSON
        if let url = Bundle.main.url(forResource: "VaccinationData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let schedules = try JSONDecoder().decode([VaccinationSchedule].self, from: data)
                
                // Ищем расписание для указанной страны
                if let schedule = schedules.first(where: { $0.country.lowercased() == country.lowercased() }) {
                    self.vaccinationSchedule = schedule
                } else {
                    // Если страна не найдена, используем первое доступное расписание
                    self.vaccinationSchedule = schedules.first
                }
            } catch {
                self.error = "Ошибка загрузки данных: \(error.localizedDescription)"
            }
        } else {
            self.error = "Файл с данными не найден"
        }
        
        isLoading = false
    }
    
    func getVaccinationsForAge(_ ageInMonths: Int) -> [Vaccination] {
        guard let schedule = vaccinationSchedule else { return [] }
        return schedule.vaccinations.filter { $0.ageInMonths <= ageInMonths }
    }
    
    func getUpcomingVaccinations(currentAgeInMonths: Int, monthsAhead: Int = 3) -> [Vaccination] {
        guard let schedule = vaccinationSchedule else { return [] }
        let upperBound = currentAgeInMonths + monthsAhead
        return schedule.vaccinations.filter { 
            $0.ageInMonths > currentAgeInMonths && 
            $0.ageInMonths <= upperBound && 
            !$0.isCompleted 
        }
    }
    
    func getOverdueVaccinations(currentAgeInMonths: Int) -> [Vaccination] {
        guard let schedule = vaccinationSchedule else { return [] }
        return schedule.vaccinations.filter { 
            $0.ageInMonths < currentAgeInMonths && 
            !$0.isCompleted 
        }
    }
    
    func markVaccinationAsCompleted(_ vaccination: Vaccination, date: Date, notes: String, vaccineType: String) -> Vaccination? {
        guard let schedule = vaccinationSchedule else { return nil }
        
        var updatedVaccination = vaccination
        updatedVaccination.isCompleted = true
        updatedVaccination.completedDate = date
        updatedVaccination.notes = notes
        updatedVaccination.vaccineType = vaccineType
        
        // Обновляем в расписании
        if let index = schedule.vaccinations.firstIndex(where: { $0.id == vaccination.id }) {
            var updatedSchedule = schedule
            updatedSchedule.vaccinations[index] = updatedVaccination
            vaccinationSchedule = updatedSchedule
        }
        
        return updatedVaccination
    }
    
    func addCustomVaccination(_ vaccination: Vaccination) {
        guard var schedule = vaccinationSchedule else { return }
        schedule.vaccinations.append(vaccination)
        vaccinationSchedule = schedule
    }
}