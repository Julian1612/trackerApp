import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["Alle"] + Array(allCategories).sorted()
    }

    init() {
        self.heatmapData = Array(repeating: 0.0, count: 200)
        determineCurrentRoutineTime()
        if habits.isEmpty { createSampleHabits() }
    }
    
    func habits(for category: String) -> [Habit] {
        let filtered: [Habit]
        if category == "Alle" {
            filtered = habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            filtered = habits.filter { $0.category == category }
        }
        return filtered.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // 🔥 Robuste Move-Logik
    func moveHabit(from sourceID: UUID, to destinationID: UUID) {
        guard let fromIndex = habits.firstIndex(where: { $0.id == sourceID }),
              let toIndex = habits.firstIndex(where: { $0.id == destinationID }) else { return }
        
        // Element entfernen und an neuer Stelle einfügen
        let movedHabit = habits.remove(at: fromIndex)
        habits.insert(movedHabit, at: toIndex)

        // Neue Reihenfolge speichern
        for (index, _) in habits.enumerated() {
            habits[index].sortOrder = index
        }
    }

    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime) {
        let maxOrder = habits.map { $0.sortOrder }.max() ?? 0
        let newHabit = Habit(
            title: title, emoji: emoji, type: type, currentValue: 0, goalValue: goal, unit: unit,
            recurrence: recurrence, frequency: days, reminderTime: nil, notificationEnabled: false,
            category: category, routineTime: routineTime,
            sortOrder: maxOrder + 1
        )
        DispatchQueue.main.async {
            self.habits.append(newHabit)
            self.calculateTodayScore()
        }
    }
    
    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore()
        }
    }
    
    func updateHabitProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = value
            calculateTodayScore()
        }
    }
    
    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
            calculateTodayScore()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        calculateTodayScore()
    }
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
        
        let activeHabits = habits.filter { habit in
            switch habit.recurrence {
            case .daily: return true
            case .weekly: return habit.frequency.contains(adjustedWeekday)
            case .monthly: return true
            }
        }
        
        if activeHabits.isEmpty { updateHeatmap(0.0); return }
        let completedCount = activeHabits.filter { $0.currentValue >= $0.goalValue }.count
        let score = Double(completedCount) / Double(activeHabits.count)
        updateHeatmap(score)
    }
    
    private func updateHeatmap(_ score: Double) {
        if !heatmapData.isEmpty { heatmapData[heatmapData.count - 1] = score }
    }

    private func createSampleHabits() {
        let samples = [
            Habit(title: "Wasser trinken", emoji: "💧", type: .value, currentValue: 0, goalValue: 1, unit: "Glas", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Gesundheit", routineTime: .morning, sortOrder: 0),
            Habit(title: "Bett machen", emoji: "🛏️", type: .checkmark, currentValue: 0, goalValue: 1, unit: "", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Mindset", routineTime: .morning, sortOrder: 1),
            Habit(title: "Spaziergang", emoji: "🚶", type: .value, currentValue: 0, goalValue: 15, unit: "Min", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Gesundheit", routineTime: .day, sortOrder: 2),
            Habit(title: "Deep Work", emoji: "💻", type: .value, currentValue: 0, goalValue: 1, unit: "Session", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Mindset", routineTime: .day, sortOrder: 3),
            Habit(title: "Lesen", emoji: "📖", type: .value, currentValue: 0, goalValue: 10, unit: "Seiten", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Mindset", routineTime: .evening, sortOrder: 4),
            Habit(title: "Kein Handy", emoji: "📵", type: .checkmark, currentValue: 0, goalValue: 1, unit: "", recurrence: .daily, frequency: [1,2,3,4,5,6,7], reminderTime: nil, notificationEnabled: false, category: "Gesundheit", routineTime: .evening, sortOrder: 5)
        ]
        self.habits.append(contentsOf: samples)
        calculateTodayScore()
    }
}
