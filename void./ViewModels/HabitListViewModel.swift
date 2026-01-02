import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    
    // Default auf .morning setzen (da .any entfernt wurde)
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    var morningStartHour = 5
    var dayStartHour = 11
    var eveningStartHour = 18

    var categories: [String] {
        let relevantHabits = habits.filter {
            $0.routineTime == selectedRoutineTime
        }
        let allCategories = Set(relevantHabits.map { $0.category })
        return ["Alle"] + Array(allCategories).sorted()
    }

    init() {
        var history = Array(repeating: 0.0, count: 199)
        history.append(0.0) // Heute
        self.heatmapData = history
        determineCurrentRoutineTime()
    }
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= morningStartHour && hour < dayStartHour {
            selectedRoutineTime = .morning
        } else if hour >= dayStartHour && hour < eveningStartHour {
            selectedRoutineTime = .day
        } else {
            selectedRoutineTime = .evening
        }
    }
    
    func habits(for category: String) -> [Habit] {
        let timeFiltered = habits.filter {
            $0.routineTime == selectedRoutineTime
        }
        
        if category == "Alle" {
            return timeFiltered
        } else {
            return timeFiltered.filter { $0.category == category }
        }
    }

    // --- ACTIONS ---

    // Fortschritt hinzufügen (für Slider)
    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore()
        }
    }
    
    // Habit komplett abschließen
    func completeHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = habits[index].goalValue
            calculateTodayScore()
        }
    }
    
    // 🆕 RESET: Setzt den Wert hart auf 0
    func resetHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = 0
            calculateTodayScore()
        }
    }
    
    // --- SCORE & CRUD ---
    
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        let standardWeekday = calendar.component(.weekday, from: today)
        let adjustedWeekday = (standardWeekday == 1) ? 7 : (standardWeekday - 1)
        
        let activeHabits = habits.filter { habit in
            switch habit.recurrence {
            case .daily: return true
            case .weekly: return habit.frequency.contains(adjustedWeekday)
            case .monthly: return true
            }
        }
        
        if activeHabits.isEmpty {
            updateLastHeatmapTile(0.0)
            return
        }
        
        let completedCount = activeHabits.filter { $0.currentValue >= $0.goalValue }.count
        let score = Double(completedCount) / Double(activeHabits.count)
        updateLastHeatmapTile(score)
    }
    
    private func updateLastHeatmapTile(_ score: Double) {
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

    func incrementHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if habits[index].type == .checkmark {
                habits[index].currentValue = (habits[index].currentValue == 0) ? 1 : 0
            } else {
                habits[index].currentValue += 1
            }
            calculateTodayScore()
        }
    }

    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, time: Date, notifications: Bool, category: String, routineTime: RoutineTime) {
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            recurrence: recurrence,
            frequency: days,
            reminderTime: time,
            notificationEnabled: notifications,
            category: category,
            routineTime: routineTime
        )
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.habits.append(newHabit)
                self.calculateTodayScore()
            }
        }
    }
    
    // Hilfsfunktion für Drag & Drop
    func moveHabit(from source: IndexSet, to destination: Int, currentVisibleHabits: [Habit]) {
        let itemsToMove = source.map { currentVisibleHabits[$0] }
        
        for item in itemsToMove {
            if let index = habits.firstIndex(where: { $0.id == item.id }) {
                habits.remove(at: index)
            }
        }
        
        var insertIndex = habits.count
        if destination < currentVisibleHabits.count {
            let targetItem = currentVisibleHabits[destination]
            if let targetGlobalIndex = habits.firstIndex(where: { $0.id == targetItem.id }) {
                insertIndex = targetGlobalIndex
            }
        } else if let lastVisibleItem = currentVisibleHabits.last,
                  let lastGlobalIndex = habits.firstIndex(where: { $0.id == lastVisibleItem.id }) {
            insertIndex = lastGlobalIndex + 1
        }
        
        insertIndex = min(insertIndex, habits.count)
        habits.insert(contentsOf: itemsToMove, at: insertIndex)
    }
}
