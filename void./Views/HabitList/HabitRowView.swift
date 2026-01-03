import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel

    // 🔥 FIX: Kein State mehr für das Sheet, wir brauchen das Popup nicht mehr.
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                // Direkte Interaktion ohne Fenster
                let newValue: Double
                
                if habit.type == .checkmark {
                    // Checkmark Logik: Toggle 0 oder 1
                    newValue = habit.currentValue >= habit.goalValue ? 0.0 : 1.0
                } else {
                    // Anzahl Logik: Einfach +1 hochzählen.
                    // Wenn Ziel erreicht, resettet der nächste Klick auf 0.
                    newValue = habit.currentValue >= habit.goalValue ? 0.0 : habit.currentValue + 1.0
                }
                
                // Vibrations-Feedback für besseren Vibe
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                viewModel.updateHabitProgress(for: habit, value: newValue)
            }) {
                HabitIconComponent(habit: habit)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(habit.category)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if habit.type == .value {
                Text("\(Int(habit.currentValue))/\(Int(habit.goalValue)) \(habit.unit)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            } else if habit.currentValue >= habit.goalValue {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        // 🔥 FIX: .sheet modifier komplett entfernt. Bye bye Popup! 👋
    }
}
