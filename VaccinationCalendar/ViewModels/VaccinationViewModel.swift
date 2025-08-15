import Foundation
import SwiftUI

class VaccinationViewModel: ObservableObject {
    @Published var vaccinationService = VaccinationService()
    @Published var showingOnboarding = false
    @Published var selectedVaccination: Vaccination?
    @Published var showingVaccinationDetail = false
    
    var child: Child? {
        vaccinationService.child
    }
    
    var vaccinations: [Vaccination] {
        vaccinationService.vaccinations
    }
    
    var completedVaccinations: [Vaccination] {
        vaccinationService.getCompletedVaccinations()
    }
    
    var pendingVaccinations: [Vaccination] {
        vaccinationService.getPendingVaccinations()
    }
    
    var upcomingVaccinations: [Vaccination] {
        guard let child = child else { return [] }
        return vaccinationService.getUpcomingVaccinations(for: child.ageInMonths)
    }
    
    var currentAgeVaccinations: [Vaccination] {
        guard let child = child else { return [] }
        return vaccinationService.getVaccinationsForAge(child.ageInMonths)
    }
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        if vaccinationService.child == nil {
            showingOnboarding = true
        }
    }
    
    func completeOnboarding(name: String, birthDate: Date, country: String) {
        let newChild = Child(name: name, birthDate: birthDate, country: country)
        vaccinationService.saveChild(newChild)
        showingOnboarding = false
    }
    
    func toggleVaccinationCompletion(_ vaccination: Vaccination) {
        var updatedVaccination = vaccination
        updatedVaccination.isCompleted.toggle()
        
        if updatedVaccination.isCompleted {
            updatedVaccination.completedDate = Date()
        } else {
            updatedVaccination.completedDate = nil
        }
        
        vaccinationService.updateVaccination(updatedVaccination)
    }
    
    func updateVaccinationNotes(_ vaccination: Vaccination, notes: String) {
        var updatedVaccination = vaccination
        updatedVaccination.notes = notes
        vaccinationService.updateVaccination(updatedVaccination)
    }
    
    func updateVaccinationVaccineType(_ vaccination: Vaccination, vaccineType: String) {
        var updatedVaccination = vaccination
        updatedVaccination.vaccineType = vaccineType
        vaccinationService.updateVaccination(updatedVaccination)
    }
    
    func addCustomVaccination(name: String, description: String, ageInMonths: Int, isRequired: Bool = false) {
        let ageRange = AgeRange(fromAge: ageInMonths, toAge: ageInMonths)
        let newVaccination = Vaccination(
            name: name,
            description: description,
            recommendedAge: ageRange,
            isRequired: isRequired
        )
        vaccinationService.addCustomVaccination(newVaccination)
    }
    
    func getVaccinationStatus(for vaccination: Vaccination) -> VaccinationStatus {
        guard let child = child else { return .notApplicable }
        
        let currentAge = child.ageInMonths
        
        if vaccination.isCompleted {
            return .completed
        } else if currentAge >= vaccination.recommendedAge.fromAge && currentAge <= vaccination.recommendedAge.toAge {
            return .due
        } else if currentAge < vaccination.recommendedAge.fromAge {
            return .upcoming
        } else {
            return .overdue
        }
    }
}

enum VaccinationStatus {
    case completed
    case due
    case upcoming
    case overdue
    case notApplicable
    
    var color: Color {
        switch self {
        case .completed:
            return .green
        case .due:
            return .orange
        case .upcoming:
            return .blue
        case .overdue:
            return .red
        case .notApplicable:
            return .gray
        }
    }
    
    var text: String {
        switch self {
        case .completed:
            return "Выполнено"
        case .due:
            return "Срок"
        case .upcoming:
            return "Предстоит"
        case .overdue:
            return "Просрочено"
        case .notApplicable:
            return "Не применимо"
        }
    }
}