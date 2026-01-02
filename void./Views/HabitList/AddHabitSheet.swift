import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    var editingHabit: Habit?

    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0
    @State private var unit = "min"
    @State private var category = "Allgemein"
    @State private var recurrence: HabitRecurrence = .daily
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    @State private var reminderTime = Date()
    @State private var notificationEnabled = false
    
    // Default-Wert (wird im UI nicht mehr angezeigt)
    @State private var routineTime: RoutineTime = .morning
    
    @State private var showDeleteAlert = false

    let weekDays = ["M", "D", "M", "D", "F", "S", "S"]

    init(viewModel: HabitListViewModel, editingHabit: Habit? = nil) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        
        if let habit = editingHabit {
            _title = State(initialValue: habit.title)
            _emoji = State(initialValue: habit.emoji)
            _selectedType = State(initialValue: habit.type)
            _goal = State(initialValue: habit.goalValue)
            _unit = State(initialValue: habit.unit)
            _category = State(initialValue: habit.category)
            _recurrence = State(initialValue: habit.recurrence)
            _selectedDays = State(initialValue: habit.frequency)
            _reminderTime = State(initialValue: habit.reminderTime ?? Date())
            _notificationEnabled = State(initialValue: habit.notificationEnabled)
            _routineTime = State(initialValue: habit.routineTime)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basics").foregroundColor(.black)) {
                    HStack {
                        TextField("Emoji", text: $emoji).frame(width: 45).multilineTextAlignment(.center)
                        Divider()
                        TextField("Titel", text: $title)
                    }
                    // Kategorie direkt hier, statt extra Sektion
                    TextField("Kategorie (z.B. Sport)", text: $category)
                }
                
                // "Zuordnung" (RoutineTime) ist hier GELÖSCHT 🗑️
                
                Section(header: Text("Wann?").foregroundColor(.black)) {
                    Picker("Wiederholung", selection: $recurrence) {
                        ForEach(HabitRecurrence.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if recurrence == .weekly {
                        HStack {
                            ForEach(1...7, id: \.self) { day in
                                Text(weekDays[day-1])
                                    .font(.system(size: 12, weight: .bold))
                                    .frame(width: 32, height: 32)
                                    .background(selectedDays.contains(day) ? Color.black : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedDays.contains(day) ? .white : .black)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        if selectedDays.contains(day) { selectedDays.remove(day) }
                                        else { selectedDays.insert(day) }
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
                            TextField("10", value: $goal, format: .number).keyboardType(.decimalPad)
                            TextField("Einheit", text: $unit)
                        }
                    }
                }
                
                if editingHabit != nil {
                    Section {
                        Button(action: { showDeleteAlert = true }) {
                            Text("Routine löschen").foregroundColor(.red)
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
                    Button("Speichern") { saveAction() }
                        .foregroundColor(.black)
                        .disabled(title.isEmpty)
                }
            }
            .alert("Löschen?", isPresented: $showDeleteAlert) {
                Button("Löschen", role: .destructive) {
                    if let habit = editingHabit {
                        viewModel.deleteHabit(habit)
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveAction() {
        if let originalHabit = editingHabit {
            var updated = originalHabit
            updated.title = title
            updated.emoji = emoji
            updated.type = selectedType
            updated.goalValue = goal
            updated.unit = selectedType == .checkmark ? "✓" : unit
            updated.recurrence = recurrence
            updated.frequency = selectedDays
            updated.reminderTime = reminderTime
            updated.notificationEnabled = notificationEnabled
            updated.category = category
            // routineTime bleibt unverändert oder default
            
            viewModel.updateHabit(updated)
        } else {
            viewModel.addHabit(
                title: title,
                emoji: emoji,
                type: selectedType,
                goal: goal,
                unit: selectedType == .checkmark ? "✓" : unit,
                recurrence: recurrence,
                days: selectedDays,
                time: reminderTime,
                notifications: notificationEnabled,
                category: category,
                routineTime: routineTime
            )
        }
        dismiss()
    }
}
