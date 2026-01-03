import Foundation
import SwiftData

// Enum definitions remain Codable for persistence
enum HabitType: String, Codable {
    case value
    case checkmark
}

enum HabitRecurrence: String, CaseIterable, Identifiable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
}

enum RoutineTime: String, CaseIterable, Identifiable, Codable {
    case morning = "Morning"
    case day = "Day"
    case evening = "Evening"
    
    var id: String { self.rawValue }
}

/// The core data model, now upgraded to a SwiftData @Model class.
/// This allows automatic persistence and relationship management.
@Model
final class Habit: Identifiable {
    // Unique identifier for the habit
    @Attribute(.unique) var id: UUID
    
    var title: String
    var emoji: String
    var type: HabitType
    var currentValue: Double
    var goalValue: Double
    var unit: String
    
    // Configuration
    var recurrence: HabitRecurrence
    var frequency: [Int] // Stores weekdays: 1=Sun, 2=Mon, ..., 7=Sat (Calendar Standard)
    
    // ✨ NEW: Relationship to multiple reminders
    @Relationship(deleteRule: .cascade) var reminders: [HabitReminder] = []
    
    var category: String
    var routineTime: RoutineTime
    
    // Sorting order in the list
    var sortOrder: Int
    
    // Helper to determine if the habit is completed
    var isCompleted: Bool {
        return currentValue >= goalValue
    }
    
    // Initializer
    init(id: UUID = UUID(),
         title: String,
         emoji: String,
         type: HabitType,
         currentValue: Double = 0,
         goalValue: Double,
         unit: String,
         recurrence: HabitRecurrence = .daily,
         frequency: [Int] = [1,2,3,4,5,6,7],
         category: String,
         routineTime: RoutineTime,
         sortOrder: Int) {
        
        self.id = id
        self.title = title
        self.emoji = emoji
        self.type = type
        self.currentValue = currentValue
        self.goalValue = goalValue
        self.unit = unit
        self.recurrence = recurrence
        self.frequency = frequency
        self.category = category
        self.routineTime = routineTime
        self.sortOrder = sortOrder
    }
}
