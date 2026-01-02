import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []

    init() {
        // Initialisiere die Heatmap mit Zufallswerten für den Look
        self.heatmapData = (0..<200).map { _ in Double.random(in: 0...1) }
    }

    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, days: Set<Int>, category: String) {
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            frequency: days,
            category: category
        )
        
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.habits.append(newHabit)
            }
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
}
