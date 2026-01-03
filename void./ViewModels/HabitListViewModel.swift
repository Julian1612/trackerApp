import SwiftUI
import Combine
import SwiftData

/// The central brain managing data flow between SwiftData and the View.
class HabitListViewModel: ObservableObject {
    // MARK: - Properties
    
    private var modelContext: ModelContext?
    
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }

    // MARK: - Initialization
    
    init() {
        self.heatmapData = Array(repeating: 0.0, count: 100)
        determineCurrentRoutineTime()
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchHabits()
        calculateHistoricalHeatmap()
    }
    
    // MARK: - Data Operations
    
    func fetchHabits() {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
            self.habits = try context.fetch(descriptor)
            
            if habits.isEmpty {
                createSampleHabits()
            }
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
    
    func logProgress(for habit: Habit, value: Double) {
        guard let context = modelContext else { return }
        
        habit.currentValue += value
        
        let newLog = ActivityLog(habitID: habit.id, date: Date(), value: value)
        context.insert(newLog)
        
        saveContext()
        calculateHistoricalHeatmap()
    }
    
    func updateHabitProgress(for habit: Habit, value: Double) {
        habit.currentValue = value
        saveContext()
        calculateHistoricalHeatmap()
    }
    
    func updateHabit(_ updatedHabit: Habit) {
        // ✨ Trigger Notification Reschedule
        NotificationManager.shared.scheduleNotifications(for: updatedHabit)
        
        saveContext()
        fetchHabits()
    }
    
    /// Enhanced addHabit to include reminders
    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime, reminders: [HabitReminder]) {
        guard let context = modelContext else { return }
        let maxOrder = habits.map { $0.sortOrder }.max() ?? 0
        
        let newHabit = Habit(
            title: title, emoji: emoji, type: type, currentValue: 0, goalValue: goal, unit: unit,
            recurrence: recurrence, frequency: Array(days), category: category, routineTime: routineTime, sortOrder: maxOrder + 1
        )
        
        // Attach reminders
        newHabit.reminders = reminders
        
        context.insert(newHabit)
        saveContext()
        
        // ✨ Schedule Notifications
        NotificationManager.shared.scheduleNotifications(for: newHabit)
        
        fetchHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        // ✨ Clean up notifications
        NotificationManager.shared.cancelNotifications(for: habit)
        
        modelContext?.delete(habit)
        saveContext()
        fetchHabits()
    }
    
    func moveHabit(from sourceID: UUID, to destinationID: UUID) {
        guard let fromIndex = habits.firstIndex(where: { $0.id == sourceID }),
              let toIndex = habits.firstIndex(where: { $0.id == destinationID }) else { return }
        
        let movedHabit = habits.remove(at: fromIndex)
        habits.insert(movedHabit, at: toIndex)
        
        for (index, habit) in habits.enumerated() { habit.sortOrder = index }
        saveContext()
    }
    
    // MARK: - Filtering Logic
    
    func getVisibleHabits(for category: String) -> [Habit] {
        let filtered: [Habit]
        if category == "All" {
            filtered = habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            filtered = habits.filter { $0.category == category }
        }
        return filtered.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Helpers
    
    func calculateHistoricalHeatmap() {
        guard let context = modelContext, !habits.isEmpty else { return }
        
        // 1. Fetch Logs
        let descriptor = FetchDescriptor<ActivityLog>()
        guard let logs = try? context.fetch(descriptor) else { return }
        
        var newHeatmap: [Double] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 2. Iterate back 100 days
        for offset in (0..<100).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            
            // Logs for this day
            let daysLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            // Active habits for this weekday
            let weekday = calendar.component(.weekday, from: date)
            let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
            
            let activeHabits = habits.filter { habit in
                switch habit.recurrence {
                case .daily: return true
                case .weekly: return habit.frequency.contains(adjustedWeekday)
                case .monthly: return true
                }
            }
            
            if activeHabits.isEmpty {
                newHeatmap.append(0.0)
                continue
            }
            
            // Calculate Score
            var completedCount = 0
            for habit in activeHabits {
                let habitLogsValue = daysLogs
                    .filter { $0.habitID == habit.id }
                    .reduce(0) { $0 + $1.value }
                
                let isToday = calendar.isDateInToday(date)
                let totalValue = isToday ? max(habit.currentValue, habitLogsValue) : habitLogsValue
                
                if totalValue >= habit.goalValue {
                    completedCount += 1
                }
            }
            let score = Double(completedCount) / Double(activeHabits.count)
            newHeatmap.append(score)
        }
        
        DispatchQueue.main.async {
            self.heatmapData = newHeatmap
        }
    }
    
    private func saveContext() {
        try? modelContext?.save()
    }
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    private func createSampleHabits() {
        // Updated for new init signature without old reminder params
        guard let context = modelContext else { return }
        let s1 = Habit(title: "Drink Water", emoji: "💧", type: .value, goalValue: 8, unit: "Glasses", category: "Health", routineTime: .morning, sortOrder: 0)
        let s2 = Habit(title: "Read", emoji: "📖", type: .value, goalValue: 10, unit: "Pages", category: "Mindset", routineTime: .evening, sortOrder: 1)
        context.insert(s1)
        context.insert(s2)
        saveContext()
        fetchHabits()
    }
}
