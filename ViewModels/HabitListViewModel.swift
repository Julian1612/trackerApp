import SwiftUI
import Combine
import SwiftData
import UserNotifications

class HabitListViewModel: ObservableObject {
    private var modelContext: ModelContext?
    @Published var habits: [Habit] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    @Published var routineForSettings: RoutineTime? = nil
    
    // Custom Routine Settings (könnten auch in UserDefaults gespeichert werden)
    @Published var routineStartTimes: [RoutineTime: Date] = [
        .morning: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!,
        .day: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!,
        .evening: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
    ]

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchHabits()
    }
    
    func fetchHabits() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
        self.habits = (try? context.fetch(descriptor)) ?? []
    }

    func scheduleNotifications(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: habits.map { "\($0.id.uuidString)" })
        
        guard habit.notificationEnabled else { return }
        
        for reminder in habit.reminders {
            let content = UNMutableNotificationContent()
            content.title = habit.title
            content.body = reminder.message.isEmpty ? "Zeit für \(habit.emoji)!" : reminder.message
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func updateHabit(_ habit: Habit) {
        scheduleNotifications(for: habit)
        try? modelContext?.save()
        fetchHabits()
    }
}