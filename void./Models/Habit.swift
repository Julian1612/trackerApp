import Foundation

enum HabitType {
    case counter, duration, checkmark
}

enum HabitRecurrence: String, CaseIterable, Identifiable {
    case daily = "Täglich"
    case weekly = "Wöchentlich"
    case monthly = "Monatlich"
    var id: String { self.rawValue }
}

struct Habit: Identifiable {
    let id = UUID()
    var title: String
    var emoji: String
    var type: HabitType
    var currentValue: Double
    var goalValue: Double
    var unit: String
    
    // Konfiguration
    var recurrence: HabitRecurrence
    var frequency: Set<Int>
    var reminderTime: Date?
    var notificationEnabled: Bool
    var category: String // Wichtig für die Tabs!
}
