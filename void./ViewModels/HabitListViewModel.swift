import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    // Globale Kategorien (Funktionieren unabhängig von der Tageszeit)
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
    
    // Filter-Logik für die View
    func habits(for category: String) -> [Habit] {
        if category == "Alle" {
            return habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            return habits.filter { $0.category == category }
        }
    }

    // 🔥 Diese Funktion muss exakt so heißen wie im Sheet aufgerufen
    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore() // Wichtig für die Heatmap!
        }
    }

    func calculateTodayScore() {
        // ... (deine Score-Logik zur Berechnung der Heatmap)
        let completedCount = habits.filter { $0.currentValue >= $0.goalValue }.count
        let score = habits.isEmpty ? 0.0 : Double(completedCount) / Double(habits.count)
        if !heatmapData.isEmpty {
            heatmapData[heatmapData.count - 1] = score
        }
    }

    func deleteHabit(_ habit: Habit) {
        withAnimation {
            habits.removeAll { $0.id == habit.id }
            calculateTodayScore()
        }
    }

    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
            calculateTodayScore()
        }
    }

    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime) {
        let newHabit = Habit(title: title, emoji: emoji, type: type, currentValue: 0, goalValue: goal, unit: unit, recurrence: recurrence, frequency: days, reminderTime: nil, notificationEnabled: false, category: category, routineTime: routineTime)
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.habits.append(newHabit)
                self.calculateTodayScore()
            }
        }
    }
}
