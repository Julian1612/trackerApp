import SwiftUI

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
    
    // ✨ Frequency / Recurrence State
    @State private var recurrence: HabitRecurrence = .daily
    // 1 = Sun, 2 = Mon, etc. (Calendar standard)
    @State private var selectedWeekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    
    // ✨ Notification State
    @State private var tempReminders: [HabitReminder] = []

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
            
            // Load recurrence
            _recurrence = State(initialValue: habit.recurrence)
            _selectedWeekdays = State(initialValue: Set(habit.frequency))
            
            // Load existing reminders
            _tempReminders = State(initialValue: habit.reminders)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Details
                Section(header: Text("Details")) {
                    HStack(spacing: 15) {
                        TextField("Emoji", text: $emoji)
                            .font(.system(size: 25))
                            .frame(width: 45, height: 45)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                        
                        TextField("What needs to be done?", text: $title)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Category", text: $category)
                    }
                }
                
                // MARK: - Tagesabschnitt (Renamed from Frequency)
                Section(header: Text("Tagesabschnitt")) {
                    Picker("When?", selection: $routineTime) {
                        ForEach(RoutineTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Real Frequency (New Section)
                Section(header: Text("Frequency")) {
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(HabitRecurrence.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if recurrence == .weekly {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Active Days")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 0) {
                                ForEach(1...7, id: \.self) { day in
                                    WeekdayButton(dayIndex: day, isSelected: selectedWeekdays.contains(day)) {
                                        toggleDay(day)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Goal
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
                
                // MARK: - Reminders
                Section(header: Text("Reminders")) {
                    ForEach($tempReminders) { $reminder in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                DatePicker("Time", selection: $reminder.time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                Toggle("", isOn: $reminder.isEnabled)
                                    .labelsHidden()
                            }
                            
                            if reminder.isEnabled {
                                Toggle("Custom Message", isOn: $reminder.isCustomMessage)
                                    .font(.caption)
                                    .tint(.black)
                                
                                if reminder.isCustomMessage {
                                    TextField("Enter motivational quote...", text: Binding(
                                        get: { reminder.customMessage ?? "" },
                                        set: { reminder.customMessage = $0 }
                                    ))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                } else {
                                    Text("✨ Using rotating vibe check messages")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteReminder)
                    
                    Button(action: addReminder) {
                        Label("Add Reminder", systemImage: "bell.badge.plus")
                            .font(.system(size: 14, weight: .medium))
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
    
    private func toggleDay(_ day: Int) {
        if selectedWeekdays.contains(day) {
            // Prevent removing the last day (gotta do something at least once, right?)
            if selectedWeekdays.count > 1 {
                selectedWeekdays.remove(day)
            }
        } else {
            selectedWeekdays.insert(day)
        }
    }
    
    private func addReminder() {
        withAnimation {
            let defaultDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            let newReminder = HabitReminder(time: defaultDate, isEnabled: true, isCustomMessage: false)
            tempReminders.append(newReminder)
        }
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        tempReminders.remove(atOffsets: offsets)
    }
    
    private func saveHabit() {
        // Final frequency validation
        var finalFrequency: [Int]
        
        switch recurrence {
        case .daily:
            finalFrequency = [1, 2, 3, 4, 5, 6, 7]
        case .weekly:
            finalFrequency = Array(selectedWeekdays)
        case .monthly:
            // Placeholder: "1" means just needed once a month logically,
            // or we could track specific day of month later.
            // keeping it simple for now.
            finalFrequency = [1]
        }
        
        if let habit = editingHabit {
            // Update
            habit.title = title
            habit.emoji = emoji
            habit.category = category
            habit.routineTime = routineTime
            habit.type = selectedType
            habit.goalValue = goalValue
            habit.unit = selectedType == .checkmark ? "" : unit
            
            // Update Frequency stuff
            habit.recurrence = recurrence
            habit.frequency = finalFrequency
            
            habit.reminders = tempReminders
            
            viewModel.updateHabit(habit)
        } else {
            // Create
            viewModel.addHabit(
                title: title,
                emoji: emoji,
                type: selectedType,
                goal: goalValue,
                unit: unit,
                recurrence: recurrence,
                days: Set(finalFrequency),
                category: category,
                routineTime: routineTime,
                reminders: tempReminders
            )
        }
    }
}

// MARK: - Helper Views

/// A cute little button for weekdays.
struct WeekdayButton: View {
    let dayIndex: Int
    let isSelected: Bool
    let action: () -> Void
    
    var label: String {
        let formatter = DateFormatter()
        // Returns "S", "M", "T", etc.
        return formatter.veryShortWeekdaySymbols[dayIndex - 1]
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 35)
                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Rectangle()) // Makes them touch like segments
        }
        .buttonStyle(.plain)
    }
}
