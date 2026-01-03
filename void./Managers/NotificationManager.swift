import UserNotifications
import Foundation

/// Manages local notifications with main character energy. 💅
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Requests permission to slide into the user's DMs (Notification Center).
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🚫 Notification auth failed: \(error.localizedDescription)")
            } else {
                print("✅ Notification auth status: \(granted ? "Granted" : "Denied")")
            }
        }
    }
    
    /// Schedules all reminders for a specific habit.
    /// First clears old vibes to avoid clutter.
    func scheduleNotifications(for habit: Habit) {
        // 1. Clean up old mess
        cancelNotifications(for: habit)
        
        // 2. Check if we have active reminders
        let activeReminders = habit.reminders.filter { $0.isEnabled }
        guard !activeReminders.isEmpty else { return }
        
        // 3. Schedule new ones
        for reminder in activeReminders {
            let content = UNMutableNotificationContent()
            content.title = "\(habit.emoji) \(habit.title)"
            
            // Rotate the message if it's not custom
            if reminder.isCustomMessage, let customText = reminder.customMessage, !customText.isEmpty {
                content.body = customText
            } else {
                content.body = NotificationMessages.randomVibe()
            }
            
            content.sound = .default
            
            // Extract components (Hour & Minute)
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Unique ID: HabitID + ReminderID
            let requestID = "\(habit.id.uuidString)-\(reminder.id.uuidString)"
            let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule: \(error)")
                } else {
                    print("✨ Scheduled: \(requestID)")
                }
            }
        }
    }
    
    /// Cancels all notifications for a given habit.
    func cancelNotifications(for habit: Habit) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let habitPrefix = habit.id.uuidString
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(habitPrefix) }
                .map { $0.identifier }
            
            if !idsToRemove.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
                print("🗑️ Cancelled \(idsToRemove.count) notifications for \(habit.title)")
            }
        }
    }
}
