import SwiftUI

struct AddVaccinationView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode

    @State private var optionalVaccinations: [Vaccination] = []

    private func loadOptions() {
        guard let schedule = dataStore.scheduleForCurrentCountry() else { return }
        optionalVaccinations = schedule.optional.filter { opt in
            !dataStore.records.contains(where: { $0.vaccination.name == opt.name })
        }
    }

    var body: some View {
        List(optionalVaccinations) { vaccination in
            Button(action: {
                dataStore.addOptionalVaccination(vaccination)
                presentationMode.wrappedValue.dismiss()
            }) {
                VStack(alignment: .leading) {
                    Text(vaccination.name).font(.headline)
                    Text(vaccination.description).font(.subheadline)
                }
            }
        }
        .onAppear { loadOptions() }
        .navigationTitle("Добавить прививку")
    }
}