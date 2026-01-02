import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    
    // Wenn gesetzt, sind wir im Bearbeitungs-Modus
    var editingHabit: Habit?

    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0
    @State private var unit = "min"
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    @State private var category = "Allgemein"
    
    // State für den Warn-Dialog
    @State private var showDeleteAlert = false

    let weekDays = ["M", "D", "M", "D", "F", "S", "S"]

    init(viewModel: HabitListViewModel, editingHabit: Habit? = nil) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        
        // Werte vorbefüllen
        if let habit = editingHabit {
            _title = State(initialValue: habit.title)
            _emoji = State(initialValue: habit.emoji)
            _selectedType = State(initialValue: habit.type)
            _goal = State(initialValue: habit.goalValue)
            _unit = State(initialValue: habit.unit)
            _selectedDays = State(initialValue: habit.frequency)
            _category = State(initialValue: habit.category)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basics").foregroundColor(.black)) {
                    HStack {
                        TextField("Emoji", text: $emoji)
                            .frame(width: 45)
                            .multilineTextAlignment(.center)
                        Divider()
                        TextField("Titel der Routine", text: $title)
                    }
                }
                
                Section(header: Text("Wiederholung").foregroundColor(.black)) {
                    HStack {
                        ForEach(1...7, id: \.self) { day in
                            Text(weekDays[day-1])
                                .font(.system(size: 12, weight: .bold))
                                .frame(width: 32, height: 32)
                                .background(selectedDays.contains(day) ? Color.black : Color.gray.opacity(0.1))
                                .foregroundColor(selectedDays.contains(day) ? .white : .black)
                                .clipShape(Circle())
                                .onTapGesture {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                        }
                    }
                }
                
                Section(header: Text("Ziel").foregroundColor(.black)) {
                    Picker("Typ", selection: $selectedType) {
                        Text("Check").tag(HabitType.checkmark)
                        Text("Dauer").tag(HabitType.duration)
                        Text("Zähler").tag(HabitType.counter)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedType != .checkmark {
                        HStack {
                            Text("Ziel:")
                            Spacer()
                            TextField("10", value: $goal, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            TextField("Einheit", text: $unit).frame(width: 50)
                        }
                    }
                }
                
                Section(header: Text("Kategorie").foregroundColor(.black)) {
                    TextField("Kategorie", text: $category)
                }
                
                // Löschen-Button nur anzeigen, wenn wir bearbeiten
                if editingHabit != nil {
                    Section {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Routine löschen")
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingHabit == nil ? "Neue Routine" : "Bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }.foregroundColor(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveAction()
                    }
                    .foregroundColor(.black)
                    .disabled(title.isEmpty)
                }
            }
            // Der finale Warn-Dialog
            .alert("Routine wirklich löschen?", isPresented: $showDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    if let habit = editingHabit {
                        viewModel.deleteHabit(habit)
                        dismiss()
                    }
                }
            } message: {
                Text("Alle getrackten Daten gehen unwiderruflich verloren.")
            }
        }
    }

    private func saveAction() {
        if let originalHabit = editingHabit {
            // Update existierenden Habit
            var updated = originalHabit
            updated.title = title
            updated.emoji = emoji
            updated.type = selectedType
            updated.goalValue = goal
            updated.unit = selectedType == .checkmark ? "✓" : unit
            updated.frequency = selectedDays
            updated.category = category
            
            viewModel.updateHabit(updated)
        } else {
            // Neuen Habit erstellen
            viewModel.addHabit(
                title: title,
                emoji: emoji,
                type: selectedType,
                goal: goal,
                unit: selectedType == .checkmark ? "✓" : unit,
                days: selectedDays,
                category: category
            )
        }
        dismiss()
    }
}
