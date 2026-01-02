import Foundation

enum HabitType {
    case counter, duration, checkmark
}

struct Habit: Identifiable {
    let id = UUID()
    var title: String
    var emoji: String
    var type: HabitType
    var currentValue: Double
    var goalValue: Double
    var unit: String
    var frequency: Set<Int> // 1=Mo, 7=So
    var category: String
}
