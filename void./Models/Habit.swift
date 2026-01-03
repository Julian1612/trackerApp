import Foundation

enum HabitType: String, Codable {
    case value, checkmark // Dauer & Zähler sind jetzt eins: 'value'
}

enum HabitRecurrence: String, CaseIterable, Identifiable, Codable {
    case daily = "Täglich"
    case weekly = "Wöchentlich"
    case monthly = "Monatlich"
    var id: String { self.rawValue }
}

enum RoutineTime: String, CaseIterable, Identifiable, Codable {
    case morning = "Morgen"
    case day = "Tag"
    case evening = "Abend"
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
    var recurrence: HabitRecurrence
    var frequency: Set<Int>
    var reminderTime: Date?
    var notificationEnabled: Bool
    var category: String
    var routineTime: RoutineTime
}
