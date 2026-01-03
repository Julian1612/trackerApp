import SwiftUI

/// A sheet to create a new habit or edit an existing one.
struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
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

    // MARK: - Initialization
    init(viewModel: HabitListViewModel, editingHabit: Habit? = nil) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        
        // If we are editing, pre-fill the fields with existing data
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
                // Section for basic habit info
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
                        TextField("New Category", text: $category)
                            .padding(.vertical, 5)
                        
                        // Quick selection for existing categories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.categories.filter { $0 != "All" && $0 != "Alle" }, id: \.self) { existingCat in
                                    Button(action: { category = existingCat }) {
                                        Text(existingCat)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(category == existingCat ? ColorPalette.primary : Color.gray.opacity(0.1))
                                            .foregroundColor(category == existingCat ? ColorPalette.background : ColorPalette.primary)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                // Section for timing
                Section(header: Text("Frequency")) {
                    Picker("When?", selection: $routineTime) {
                        ForEach(RoutineTime.allCases) { time in
                            // Ensure English display regardless of Enum rawValue
                            Text(englishRoutineName(for: time)).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Section for goal setting
                Section(header: Text("Set Goal")) {
                    Picker("Mode", selection: $selectedType) {
                        Text("Checkmark").tag(HabitType.checkmark)
                        Text("Value").tag(HabitType.value)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedType == .value {
                        HStack {
                            TextField("Goal (e.g. 30)", value: $goalValue, format: .number)
                                .keyboardType(.decimalPad)
                            Divider().frame(height: 20)
                            TextField("Unit (Min, Liter...)", text: $unit)
                        }
                        .padding(.vertical, 5)
                    }
                }

                // Delete option only for existing habits
                if editingHabit != nil {
                    Button("Delete Habit", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(editingHabit == nil ? "Create" : "Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveHabit()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.primary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .alert("Delete Habit?", isPresented: $showDeleteAlert) {
                Button("Yes, delete it", role: .destructive) {
                    if let habit = editingHabit {
                        viewModel.deleteHabit(habit)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Helper Methods
    
    private func saveHabit() {
        if let habit = editingHabit {
            // Update existing habit
            habit.title = title
            habit.emoji = emoji
            habit.category = category
            habit.routineTime = routineTime
            habit.type = selectedType
            habit.goalValue = goalValue
            habit.unit = selectedType == .checkmark ? "" : unit
            viewModel.updateHabit(habit)
        } else {
            // Create new habit
            viewModel.addHabit(
                title: title,
                emoji: emoji,
                type: selectedType,
                goal: goalValue,
                unit: selectedType == .checkmark ? "" : unit,
                recurrence: .daily,
                days: [1,2,3,4,5,6,7],
                category: category,
                routineTime: routineTime
            )
        }
    }
    
    // Helper to ensure English labels even if Model is legacy
    private func englishRoutineName(for time: RoutineTime) -> String {
        switch time {
        case .morning: return "Morning"
        case .day: return "Day"
        case .evening: return "Evening"
        }
    }
}
