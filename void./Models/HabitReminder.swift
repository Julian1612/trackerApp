import Foundation
import SwiftData

/// Represents a single notification trigger.
/// Because one reminder is basically gaslighting yourself into forgetting. 🧠
@Model
final class HabitReminder: Identifiable {
    var id: UUID
    var time: Date
    var isEnabled: Bool
    var isCustomMessage: Bool
    var customMessage: String?
    
    // Relationship back to the parent (optional, but good practice)
    // var habit: Habit?
    
    init(id: UUID = UUID(), time: Date, isEnabled: Bool = true, isCustomMessage: Bool = false, customMessage: String? = nil) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.isCustomMessage = isCustomMessage
        self.customMessage = customMessage
    }
}
