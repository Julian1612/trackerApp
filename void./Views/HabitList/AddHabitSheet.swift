import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    
    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0
    @State private var unit = "min"
    @State private var selectedDays: Set<Int> = [1,2,3,4,5,6,7]
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var category = "Allgemein"

    let weekDays = ["M", "D", "M", "D", "F", "S", "S"]

    var body: some View {
        NavigationView {
            Form {
                Section("Basics") {
                    HStack {
                        TextField("Emoji", text: $emoji).frame(width: 40)
                        TextField("Titel", text: $title)
                    }
                }
                Section("Wiederholung") {
                    HStack {
                        ForEach(1...7, id: \.self) { day in
                            Text(weekDays[day-1])
                                .frame(width: 30, height: 30)
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
                Section("Ziel") {
                    Picker("Typ", selection: $selectedType) {
                        Text("Check").tag(HabitType.checkmark)
                        Text("Dauer").tag(HabitType.duration)
                        Text("Zähler").tag(HabitType.counter)
                    }
                    if selectedType != .checkmark {
                        TextField("Einheit", text: $unit)
                        Stepper("Zielwert: \(Int(goal))", value: $goal, in: 1...1000)
                    }
                }
                Section("Erinnerung") {
                    Toggle("Benachrichtigung", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Uhrzeit", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Konfiguration")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.addHabit(title: title, emoji: emoji, type: selectedType, goal: goal, unit: unit, days: selectedDays, category: category)
                        dismiss()
                    }.foregroundColor(.black)
                }
            }
        }
    }
}
