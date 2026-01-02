import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    
    // Aktuell ausgewählte Tageszeit für den "Alle"-Filter
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    // Zeit-Konfigurationen
    var morningStartHour = 5
    var dayStartHour = 11
    var eveningStartHour = 18

    // 🔥 NEU: Kategorien sind jetzt global über alle Habits hinweg
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["Alle"] + Array(allCategories).sorted()
    }

    init() {
        // Initialisierung der Heatmap mit 200 Tagen (Placeholder)
        self.heatmapData = Array(repeating: 0.0, count: 200)
        determineCurrentRoutineTime()
    }
    
    // Ermittelt die Routine basierend auf der aktuellen Uhrzeit
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
    
    // 🔥 NEU: Die Logik für den globalen Kategorie-Filter
    func habits(for category: String) -> [Habit] {
        if category == "Alle" {
            // Filtert nach der gewählten Tageszeit
            return habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            // Zeigt alle Habits der Kategorie, egal welche Tageszeit zugeordnet ist
            return habits.filter { $0.category == category }
        }
    }

    // --- ACTIONS ---

    // Funktion für das LogProgressSheet (Additiv)
    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore()
        }
    }
    
    // Funktion für das QuickLogSheet (Absoluter Wert oder Reset)
    func updateHabitProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = value
            calculateTodayScore()
        }
    }
    
    func resetHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = 0
            calculateTodayScore()
        }
    }
    
    // --- SCORE & HEATMAP ---
    
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        let standardWeekday = calendar.component(.weekday, from: today)
        let adjustedWeekday = (standardWeekday == 1) ? 7 : (standardWeekday - 1)
        
        // Nur Habits zählen, die heute auch fällig sind
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

    // --- CRUD ---

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
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            recurrence: recurrence,
            frequency: days,
            reminderTime: nil,
            notificationEnabled: false,
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
        }
        
        insertIndex = min(insertIndex, habits.count)
        habits.insert(contentsOf: itemsToMove, at: insertIndex)
    }
}
