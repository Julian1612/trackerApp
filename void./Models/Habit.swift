import Foundation

// Defines the way we track a habit
enum HabitType: String, Codable {
    case value
    case checkmark
}

// Defines how often the habit should be repeated
enum HabitRecurrence: String, CaseIterable, Identifiable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
}

// Defines the time of day for the habit routine
enum RoutineTime: String, CaseIterable, Identifiable, Codable {
    case morning = "Morning"
    case day = "Day"
    case evening = "Evening"
    
    var id: String { self.rawValue }
}

// The core data structure for a Habit
struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var emoji: String
    var type: HabitType
    var currentValue: Double
    var goalValue: Double
    var unit: String
    
    // Configuration
    var recurrence: HabitRecurrence
    var frequency: Set<Int> // Stores weekdays (1-7)
    var reminderTime: Date?
    var notificationEnabled: Bool
    var category: String
    var routineTime: RoutineTime
    
    // Keeps track of the position in the list
    var sortOrder: Int
    
    // Initializer with default ID for convenience
    init(id: UUID = UUID(), title: String, emoji: String, type: HabitType, currentValue: Double = 0, goalValue: Double, unit: String, recurrence: HabitRecurrence = .daily, frequency: Set<Int> = [1,2,3,4,5,6,7], reminderTime: Date? = nil, notificationEnabled: Bool = false, category: String, routineTime: RoutineTime, sortOrder: Int) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.type = type
        self.currentValue = currentValue
        self.goalValue = goalValue
        self.unit = unit
        self.recurrence = recurrence
        self.frequency = frequency
        self.reminderTime = reminderTime
        self.notificationEnabled = notificationEnabled
        self.category = category
        self.routineTime = routineTime
        self.sortOrder = sortOrder
    }
}
