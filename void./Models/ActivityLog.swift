import Foundation
import SwiftData

/// Tracks the completion of a habit on a specific date.
/// This is the key to our persistent heatmap history. No more goldfish memory! 🧠
@Model
final class ActivityLog {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var date: Date
    var value: Double
    
    init(habitID: UUID, date: Date = Date(), value: Double) {
        self.id = UUID()
        self.habitID = habitID
        self.date = date
        self.value = value
    }
}
