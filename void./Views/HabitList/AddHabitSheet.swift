import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    var editingHabit: Habit?

    @State private var title = ""
    @State private var category = "Allgemein"
    @State private var routineTime: RoutineTime = .morning
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0
    @State private var unit = "min"
    @State private var showDeleteAlert = false

    init(viewModel: HabitListViewModel, editingHabit: Habit? = nil) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        if let habit = editingHabit {
            _title = State(initialValue: habit.title)
            _category = State(initialValue: habit.category)
            _routineTime = State(initialValue: habit.routineTime)
            _selectedType = State(initialValue: habit.type)
            _goal = State(initialValue: habit.goalValue)
            _unit = State(initialValue: habit.unit)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                    TextField("Kategorie (z.B. Sport)", text: $category)
                }
                
                Section(header: Text("Wann soll der Habit anstehen?")) {
                    Picker("Tageszeit", selection: $routineTime) {
                        ForEach(RoutineTime.allCases) { time in Text(time.rawValue).tag(time) }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Ziel")) {
                    Picker("Typ", selection: $selectedType) {
                        Text("Check").tag(HabitType.checkmark)
                        Text("Dauer").tag(HabitType.duration)
                        Text("Zähler").tag(HabitType.counter)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedType != .checkmark {
                        HStack {
                            TextField("Zielwert", value: $goal, format: .number).keyboardType(.decimalPad)
                            TextField("Einheit", text: $unit)
                        }
                    }
                }

                if editingHabit != nil {
                    Section {
                        Button("Routine löschen", role: .destructive) { showDeleteAlert = true }
                    }
                }
            }
            .navigationTitle(editingHabit == nil ? "Neue Routine" : "Bearbeiten")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if let habit = editingHabit {
                            var updated = habit
                            updated.title = title
                            updated.category = category
                            updated.routineTime = routineTime
                            updated.goalValue = goal
                            updated.unit = unit
                            updated.type = selectedType
                            viewModel.updateHabit(updated)
                        } else {
                            viewModel.addHabit(title: title, emoji: "🎯", type: selectedType, goal: goal, unit: unit, recurrence: .daily, days: [1,2,3,4,5,6,7], category: category, routineTime: routineTime)
                        }
                        dismiss()
                    }
                }
            }
            .alert("Löschen?", isPresented: $showDeleteAlert) {
                Button("Löschen", role: .destructive) {
                    if let habit = editingHabit { viewModel.deleteHabit(habit); dismiss() }
                }
            }
        }
    }
}
