import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    @State private var isShowingLogSheet = false

    var body: some View {
        HStack(spacing: 12) { // Spacing etwas verringert für kompakteren Look
            Button(action: {
                if habit.type == .checkmark {
                    let newValue = habit.currentValue >= habit.goalValue ? 0.0 : 1.0
                    viewModel.updateHabitProgress(for: habit, value: newValue)
                } else {
                    isShowingLogSheet = true
                }
            }) {
                HabitIconComponent(habit: habit)
            }
            
            VStack(alignment: .leading, spacing: 0) { // Spacing 0, damit Titel & Kategorie kleben
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(habit.category)
                    .font(.system(size: 11)) // Schrift etwas kleiner für bessere Hierarchie
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
        // 🔥 FIX: Padding massiv reduziert (von 12 auf 6)
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .sheet(isPresented: $isShowingLogSheet) {
            QuickLogSheet(habit: habit, viewModel: viewModel)
        }
    }
}
