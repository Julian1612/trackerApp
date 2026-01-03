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
    
    // ✨ Notification State
    // Temporary holder for reminders before we save
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
            // Load existing reminders
            _tempReminders = State(initialValue: habit.reminders)
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
                
                // ✨ REMINDERS SECTION
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
    
    private func addReminder() {
        withAnimation {
            // Default: 9:00 AM, Vibe Mode (Standard messages)
            let defaultDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            let newReminder = HabitReminder(time: defaultDate, isEnabled: true, isCustomMessage: false)
            tempReminders.append(newReminder)
        }
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        tempReminders.remove(atOffsets: offsets)
    }
    
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
            
            // Update reminders (SwiftData handles the relationship magic)
            habit.reminders = tempReminders
            
            viewModel.updateHabit(habit)
        } else {
            // Create
            viewModel.addHabit(
                title: title, emoji: emoji, type: selectedType, goal: goalValue, unit: unit,
                recurrence: .daily, days: [1,2,3,4,5,6,7], category: category, routineTime: routineTime,
                reminders: tempReminders // Pass reminders here
            )
        }
    }
}
