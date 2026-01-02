import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    
    // NEU: Der aktuell aktive Zeit-Filter (Morgen/Tag/Abend)
    @Published var selectedRoutineTime: RoutineTime = .any
    
    // Konfigurierbare Grenzen (könnten später in einer Settings-View geändert werden)
    var morningStartHour = 5
    var dayStartHour = 11
    var eveningStartHour = 18

    // Dynamische Kategorien basierend auf der aktuellen Zeit-Auswahl
    var categories: [String] {
        let relevantHabits = habits.filter {
            // Zeige Habits der gewählten Zeit ODER "Jederzeit"-Habits
            $0.routineTime == selectedRoutineTime || $0.routineTime == .any
        }
        let allCategories = Set(relevantHabits.map { $0.category })
        return ["Alle"] + Array(allCategories).sorted()
    }

    init() {
        self.heatmapData = (0..<200).map { _ in Double.random(in: 0...1) }
        // Automatisch die richtige Tageszeit beim Start setzen
        determineCurrentRoutineTime()
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
    
    // Filter-Logik: Erst Tageszeit, dann Kategorie
    func habits(for category: String) -> [Habit] {
        // 1. Filter nach Zeit (oder "Jederzeit")
        let timeFiltered = habits.filter {
            $0.routineTime == selectedRoutineTime || $0.routineTime == .any
        }
        
        // 2. Filter nach Kategorie
        if category == "Alle" {
            return timeFiltered
        } else {
            return timeFiltered.filter { $0.category == category }
        }
    }

    // --- CRUD Operationen ---

    func deleteHabit(_ habit: Habit) {
        withAnimation {
            habits.removeAll { $0.id == habit.id }
        }
    }

    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
        }
    }

    func incrementHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if habits[index].type == .checkmark {
                habits[index].currentValue = (habits[index].currentValue == 0) ? 1 : 0
            } else {
                habits[index].currentValue += 1
            }
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
            routineTime: routineTime // Wird jetzt gespeichert
        )
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.habits.append(newHabit)
            }
        }
    }
}
