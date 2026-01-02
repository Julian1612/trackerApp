import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    // Diese Variablen lösen automatisch UI-Updates aus
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []

    init() {
        // Initialisiere nur die Heatmap-Daten für das Grid-Design
        self.heatmapData = (0..<200).map { _ in Double.random(in: 0...1) }
    }

    func addHabit(title: String, icon: String, type: HabitType, goal: Double, unit: String) {
        let newHabit = Habit(
            title: title,
            iconName: icon,
            type: type,
            currentValue: 0,
            goalValue: goal,
            displayValue: unit
        )
        
        // Update auf dem Main-Thread sicherstellen
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.habits.append(newHabit)
            }
        }
    }
}
