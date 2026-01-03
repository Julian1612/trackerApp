import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel // Kein $ hier nutzen!
    var editingHabit: Habit?

    // MARK: - State Properties
    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var category = "General"
    @State private var routineTime: RoutineTime = .morning
    @State private var selectedType: HabitType = .checkmark
    @State private var goalValue = 1.0
    @State private var unit = "Times"
    @State private var showDeleteAlert = false

    init(viewModel: HabitListViewModel, editingHabit: Habit? = nil) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        
        if let habit = editingHabit {
            _title = State(initialValue: habit.title)
            _emoji = State(initialValue: habit.emoji)
            _category = State(initialValue: habit.category)
            _routineTime = State(initialValue: habit.routineTime)
            _selectedType = State(initialValue: habit.type)
            _goalValue = State(initialValue: habit.goalValue)
            _unit = State(initialValue: habit.unit)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    HStack(spacing: 15) {
                        TextField("Emoji", text: $emoji)
                            .font(.system(size: 25))
                            .frame(width: 45, height: 45)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                        
                        TextField("What do you want to track?", text: $title)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Category", text: $category)
                        // Optional: Category Scroller hier...
                    }
                }
                
                Section(header: Text("Frequency")) {
                    Picker("When?", selection: $routineTime) {
                        ForEach(RoutineTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Goal")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Checkmark").tag(HabitType.checkmark)
                        Text("Value").tag(HabitType.value)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedType == .value {
                        HStack {
                            TextField("Goal", value: $goalValue, format: .number)
                                .keyboardType(.decimalPad)
                            TextField("Unit", text: $unit)
                        }
                    }
                }
                
                if editingHabit != nil {
                    Button("Delete Habit", role: .destructive) { showDeleteAlert = true }
                }
            }
            .navigationTitle(editingHabit == nil ? "New Habit" : "Edit Habit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Delete?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let habit = editingHabit {
                        viewModel.deleteHabit(habit)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Logic
    private func saveHabit() {
        if let habit = editingHabit {
            // Update
            habit.title = title
            habit.emoji = emoji
            habit.category = category
            habit.routineTime = routineTime
            habit.type = selectedType
            habit.goalValue = goalValue
            habit.unit = selectedType == .checkmark ? "" : unit
            
            // 🚨 HIER WAR DER CALL: Jetzt funktioniert er, weil ViewModel gefixt ist.
            viewModel.updateHabit(habit)
        } else {
            // Create
            viewModel.addHabit(
                title: title, emoji: emoji, type: selectedType, goal: goalValue, unit: unit,
                recurrence: .daily, days: [1,2,3,4,5,6,7], category: category, routineTime: routineTime
            )
        }
    }
}
