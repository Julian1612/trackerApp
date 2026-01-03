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
    }
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    func habits(for category: String) -> [Habit] {
        if category == "Alle" {
            return habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            return habits.filter { $0.category == category }
        }
    }

    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore()
        }
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
        
        if activeHabits.isEmpty {
            updateHeatmap(0.0)
            return
        }
        
        let completedCount = activeHabits.filter { $0.currentValue >= $0.goalValue }.count
        let score = Double(completedCount) / Double(activeHabits.count)
        updateHeatmap(score)
    }
    
    private func updateHeatmap(_ score: Double) {
        if !heatmapData.isEmpty {
            heatmapData[heatmapData.count - 1] = score
        }
    }

    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        calculateTodayScore()
    }

    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
            calculateTodayScore()
        }
    }
    
    // ... (innerhalb der HabitListViewModel Klasse)

    func updateHabitProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = value
            calculateTodayScore() // 🔥 Triggert das Heatmap-Update!
        }
    }

    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime) {
        let newHabit = Habit(title: title, emoji: emoji, type: type, currentValue: 0, goalValue: goal, unit: unit, recurrence: recurrence, frequency: days, reminderTime: nil, notificationEnabled: false, category: category, routineTime: routineTime)
        DispatchQueue.main.async {
            self.habits.append(newHabit)
            self.calculateTodayScore()
        }
    }
}
