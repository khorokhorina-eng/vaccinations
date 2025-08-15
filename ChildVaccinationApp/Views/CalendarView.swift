import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.records.sorted(by: { $0.dueDate < $1.dueDate })) { record in
                    VaccinationRow(record: record)
                }
            }
            .navigationTitle("Календарь прививок")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                NavigationView {
                    AddVaccinationView()
                }
            }
        }
    }
}

struct VaccinationRow: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showNoteEditor = false
    
    let record: VaccinationRecord

    var body: some View {
        HStack {
            Button(action: {
                dataStore.toggleDone(for: record.id)
            }) {
                Image(systemName: record.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(record.isDone ? .green : .gray)
            }
            VStack(alignment: .leading) {
                Text(record.vaccination.name)
                Text("Срок: \(formattedDate(record.dueDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showNoteEditor = true }) {
                Image(systemName: record.note.isEmpty ? "square.and.pencil" : "note.text")
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            NavigationView {
                NoteEditorView(record: record)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct NoteEditorView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode

    @State private var noteText: String
    let record: VaccinationRecord

    init(record: VaccinationRecord) {
        self.record = record
        _noteText = State(initialValue: record.note)
    }

    var body: some View {
        Form {
            Section(header: Text("Заметка")) {
                TextEditor(text: $noteText)
                    .frame(minHeight: 150)
            }
        }
        .navigationTitle(record.vaccination.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    dataStore.updateNote(for: record.id, note: noteText)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(DataStore.preview)
    }
}