import SwiftUI
import Combine
import SwiftData
import UserNotifications

class HabitListViewModel: ObservableObject {
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
    
    func fetchHabits() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
        self.habits = (try? context.fetch(descriptor)) ?? []
        
        
        // Recalculate heatmap on fetch
        calculateHistoricalHeatmap()
    }

    func scheduleNotifications(for habit: Habit) {
        NotificationManager.shared.scheduleNotifications(for: habit)
    }
    
    func updateHabit(_ habit: Habit) {
        scheduleNotifications(for: habit)
        try? modelContext?.save()
        fetchHabits()
    }
    
    // ✨ Updated to accept motivationText (with default nil for compatibility)
    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, motivationText: String? = nil, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime, reminders: [HabitReminder]) {
        guard let context = modelContext else { return }
        let maxOrder = habits.map { $0.sortOrder }.max() ?? 0
        
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            motivationText: motivationText, // 🆕 Pass it through
            recurrence: recurrence,
            frequency: Array(days),
            category: category,
            routineTime: routineTime,
            sortOrder: maxOrder + 1
        )
        
        newHabit.reminders = reminders
        
        context.insert(newHabit)
        try? context.save()
        
        scheduleNotifications(for: newHabit)
        fetchHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.cancelNotifications(for: habit)
        modelContext?.delete(habit)
        try? modelContext?.save()
        fetchHabits()
    }
    
    // MARK: - Progress & Heatmap
    
    func updateHabitProgress(for habit: Habit, value: Double) {
        habit.currentValue = value
        try? modelContext?.save()
        
        // Log activity
        if let context = modelContext {
            let log = ActivityLog(habitID: habit.id, date: Date(), value: value)
            context.insert(log)
            try? context.save()
        }
        
        calculateHistoricalHeatmap()
    }
    
    func logProgress(for habit: Habit, value: Double) {
        // Wrapper for manual logging sheet
        habit.currentValue += value
        updateHabitProgress(for: habit, value: habit.currentValue)
    }
    
    func moveHabit(from sourceID: UUID, to destinationID: UUID) {
        guard let fromIndex = habits.firstIndex(where: { $0.id == sourceID }),
              let toIndex = habits.firstIndex(where: { $0.id == destinationID }) else { return }
        
        let movedHabit = habits.remove(at: fromIndex)
        habits.insert(movedHabit, at: toIndex)
        
        for (index, habit) in habits.enumerated() { habit.sortOrder = index }
        try? modelContext?.save()
    }
    
    // MARK: - Filtering Logic
    
    func getVisibleHabits(for category: String) -> [Habit] {
        let filtered: [Habit]
        
        // Time Filter logic needs to respect selectedRoutineTime
        // But also check if habit is due today based on Frequency!
        let relevantHabits = habits.filter { habit in
            if habit.recurrence == .daily { return true }
            if habit.recurrence == .monthly { return true } // Simplified
            if habit.recurrence == .weekly {
                let weekday = Calendar.current.component(.weekday, from: Date())
                // Calendar returns 1 for Sunday, but our Set uses same logic
                return habit.frequency.contains(weekday)
            }
            return true
        }
        
        if category == "All" {
            filtered = relevantHabits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            filtered = relevantHabits.filter { $0.category == category }
        }
        return filtered.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Helpers
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    func calculateHistoricalHeatmap() {
        guard let context = modelContext, !habits.isEmpty else { return }
        
        let descriptor = FetchDescriptor<ActivityLog>()
        guard let logs = (try? context.fetch(descriptor)) else { return }
        
        var newHeatmap: [Double] = []
        let calendar = Calendar.current
        let today = Date()
        
        for offset in (0..<100).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let daysLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let weekday = calendar.component(.weekday, from: date)
            
            let activeHabits = habits.filter { habit in
                switch habit.recurrence {
                case .daily: return true
                case .weekly: return habit.frequency.contains(weekday)
                case .monthly: return true
                }
            }
            
            if activeHabits.isEmpty {
                newHeatmap.append(0.0)
                continue
            }
            
            var completedCount = 0
            for habit in activeHabits {
                let habitLogsValue = daysLogs
                    .filter { $0.habitID == habit.id }
                    .reduce(0) { $0 + $1.value }
                
                let isToday = calendar.isDateInToday(date)
                // If today, use current value from Habit model (realtime), else use logs
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
}
