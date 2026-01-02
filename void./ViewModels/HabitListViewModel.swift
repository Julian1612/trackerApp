import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    
    // Start-Wert auf Morning
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    var morningStartHour = 5
    var dayStartHour = 11
    var eveningStartHour = 18

    // Kategorien sind GLOBAL
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["Alle"] + Array(allCategories).sorted()
    }

    init() {
        // 🛠 FIX: Keine Random-Daten mehr! Alles auf 0.0 (Weiß).
        // Wir starten mit 199 leeren Tagen für die Vergangenheit.
        var history = Array(repeating: 0.0, count: 199)
        
        // +1 Slot für "Heute" (startet auch bei 0 und wird live berechnet)
        history.append(0.0)
        
        self.heatmapData = history
        
        determineCurrentRoutineTime()
        // Checkt direkt beim Start, ob für HEUTE schon was erledigt wurde
        calculateTodayScore()
    }
    
    // Ermittelt anhand der Uhrzeit den aktuellen Abschnitt
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
    
    // Filter-Logik
    func habits(for category: String) -> [Habit] {
        if category == "Alle" {
            return habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            return habits.filter { $0.category == category }
        }
    }
    
    // 🔥 DER REAL-TIME SCORE CHECKER
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        
        // Wochentag anpassen (1=Mo ... 7=So Logik, falls nötig, oder Apple Standard)
        // Hier nutzen wir Apple Standard (1=So) -> mapped auf Mo=1...So=7
        let standardWeekday = calendar.component(.weekday, from: today)
        let adjustedWeekday = (standardWeekday == 1) ? 7 : (standardWeekday - 1)
        
        // Welche Habits MÜSSEN heute erledigt werden?
        let activeHabits = habits.filter { habit in
            switch habit.recurrence {
            case .daily:
                return true
            case .weekly:
                return habit.frequency.contains(adjustedWeekday)
            case .monthly:
                return true
            }
        }
        
        // Wenn heute nichts ansteht -> Score 0.0 (Weiß)
        if activeHabits.isEmpty {
            updateLastHeatmapTile(0.0)
            return
        }
        
        // Wie viele davon hast du geschafft?
        let completedCount = activeHabits.filter { $0.currentValue >= $0.goalValue }.count
        
        // Score berechnen (0.0 bis 1.0)
        let score = Double(completedCount) / Double(activeHabits.count)
        
        updateLastHeatmapTile(score)
    }
    
    private func updateLastHeatmapTile(_ score: Double) {
        if !heatmapData.isEmpty {
            // Das letzte Element ist immer HEUTE
            heatmapData[heatmapData.count - 1] = score
        }
    }

    // --- CRUD Operationen ---

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
}
