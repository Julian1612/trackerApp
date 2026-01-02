import Foundation

enum HabitType: String, Codable {
    case counter, duration, checkmark
}

enum HabitRecurrence: String, CaseIterable, Identifiable, Codable {
    case daily = "Täglich"
    case weekly = "Wöchentlich"
    case monthly = "Monatlich"
    var id: String { self.rawValue }
}

// NEU: Die Tageszeit-Einteilung
enum RoutineTime: String, CaseIterable, Identifiable, Codable {
    case morning = "Morgen"
    case day = "Tag"
    case evening = "Abend"
    case any = "Jederzeit" // Für Habits, die immer angezeigt werden sollen
    
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
    var category: String
    
    // NEU: Wann soll das Habit erledigt werden?
    var routineTime: RoutineTime
}
