import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    var editingHabit: Habit?

    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var category = "Allgemein"
    @State private var routineTime: RoutineTime = .morning
    @State private var selectedType: HabitType = .checkmark
    @State private var goalValue = 1.0
    @State private var unit = "Mal"
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
                        
                        TextField("Was willst du tracken?", text: $title)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Neue Kategorie", text: $category)
                            .padding(.vertical, 5)
                        
                        // 🔥 Quick Category Select
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.categories.filter { $0 != "Alle" }, id: \.self) { existingCat in
                                    Button(action: { category = existingCat }) {
                                        Text(existingCat)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(category == existingCat ? Color.black : Color.gray.opacity(0.1))
                                            .foregroundColor(category == existingCat ? .white : .black)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Rhythmus")) {
                    Picker("Wann?", selection: $routineTime) {
                        ForEach(RoutineTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Ziel setzen")) {
                    Picker("Modus", selection: $selectedType) {
                        Text("Checkmark").tag(HabitType.checkmark)
                        Text("Anzahl").tag(HabitType.value)
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedType == .value {
                        HStack {
                            TextField("Ziel (z.B. 30)", value: $goalValue, format: .number)
                                .keyboardType(.decimalPad)
                            Divider().frame(height: 20)
                            TextField("Einheit (Min, Liter...)", text: $unit)
                        }
                        .padding(.vertical, 5)
                    }
                }

                if editingHabit != nil {
                    Button("Routine löschen", role: .destructive) { showDeleteAlert = true }
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(editingHabit == nil ? "Starten" : "Anpassen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        saveHabit()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.gray)
                }
            }
            .alert("Löschen?", isPresented: $showDeleteAlert) {
                Button("Ja, weg damit", role: .destructive) {
                    if let habit = editingHabit { viewModel.deleteHabit(habit); dismiss() }
                }
            }
        }
    }

    private func saveHabit() {
        if let habit = editingHabit {
            var updated = habit
            updated.title = title
            updated.emoji = emoji
            updated.category = category
            updated.routineTime = routineTime
            updated.type = selectedType
            updated.goalValue = goalValue
            updated.unit = selectedType == .checkmark ? "" : unit
            viewModel.updateHabit(updated)
        } else {
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
}
