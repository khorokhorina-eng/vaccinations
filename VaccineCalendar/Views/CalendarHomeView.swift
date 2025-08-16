import SwiftUI

struct CalendarHomeView: View {
	@EnvironmentObject private var store: AppStore
	@State private var showingAddOptional = false

	var body: some View {
		NavigationView {
			List {
				if !store.mandatoryEntries.isEmpty {
					Section(header: Text("Обязательные")) {
						ForEach(store.mandatoryEntries) { entry in
							VaccineRow(entry: entry)
						}
					}
				}

				if !store.includedOptionalEntries.isEmpty {
					Section(header: Text("Необязательные")) {
						ForEach(store.includedOptionalEntries) { entry in
							VaccineRow(entry: entry, showRemoveOptional: true)
						}
					}
				}
			}
			.listStyle(.insetGrouped)
			.navigationTitle("Календарь")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Профиль") {
						showProfileSheet()
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						showingAddOptional = true
					} label: {
						Image(systemName: "plus")
					}
					.accessibilityLabel("Добавить необязательные")
				}
			}
			.sheet(isPresented: $showingAddOptional) {
				AddOptionalView()
			}
		}
	}

	private func showProfileSheet() {
		// Minimal: reset onboarding by clearing profile
		withAnimation {
			store.profile = nil
		}
	}
}

private struct VaccineRow: View {
	@EnvironmentObject private var store: AppStore
	let entry: VaccineScheduleEntry
	var showRemoveOptional: Bool = false
	@State private var isEditingNote = false
	@State private var tempNote: String = ""

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .firstTextBaseline) {
				Text(entry.name)
					.font(.headline)
				Spacer()
				if let due = store.dueDate(for: entry) {
					Text(DateFormatters.short.string(from: due))
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
			}
			HStack {
				Toggle(isOn: Binding(
					get: { store.isCompleted(entry.id) },
					set: { _ in store.toggleCompleted(entry.id) }
				)) {
					Text("Сделано")
				}
				.toggleStyle(SwitchToggleStyle(tint: .green))

				Spacer()

				Button {
					isEditingNote = true
					tempNote = store.note(for: entry.id)
				} label: {
					Image(systemName: store.note(for: entry.id).isEmpty ? "note.text" : "note.text.badge.plus")
				}

				if showRemoveOptional {
					Button(role: .destructive) {
						store.removeOptional(entry.id)
					} label: {
						Image(systemName: "trash")
					}
				}
			}

			if !store.note(for: entry.id).isEmpty {
				Text(store.note(for: entry.id))
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
		.sheet(isPresented: $isEditingNote) {
			NavigationView {
				Form {
					TextEditor(text: $tempNote)
						.frame(minHeight: 150)
				}
				.navigationTitle("Заметка")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Отмена") { isEditingNote = false }
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Сохранить") {
							store.setNote(tempNote, for: entry.id)
							isEditingNote = false
						}
					}
				}
			}
		}
	}
}

private struct AddOptionalView: View {
	@EnvironmentObject private var store: AppStore
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationView {
			List {
				ForEach(store.availableOptionalEntries) { entry in
					Button {
						store.addOptional(entry.id)
					} label: {
						HStack {
							Text(entry.name)
							Spacer()
							if let due = store.dueDate(for: entry) {
								Text(DateFormatters.short.string(from: due))
									.foregroundColor(.secondary)
							}
						}
					}
				}
			}
			.navigationTitle("Добавить прививки")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Закрыть") { dismiss() }
				}
			}
		}
	}
}

struct CalendarHomeView_Previews: PreviewProvider {
	static var previews: some View {
		CalendarHomeView()
			.environmentObject(AppStore())
	}
}