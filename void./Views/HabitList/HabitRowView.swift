import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Button für das Icon – KEIN $ vor viewModel!
            Button(action: {
                viewModel.incrementHabit(habit)
            }) {
                ZStack {
                    Circle().stroke(Color.black, lineWidth: 1)
                    Text(habit.emoji).font(.system(size: 16))
                }
                .frame(width: 38, height: 38)
            }
            .buttonStyle(PlainButtonStyle())

            Text(habit.title)
                .font(Typography.habitTitle)
            
            Spacer()
            
            // Status-Anzeige
            Text(habit.type == .checkmark ? (habit.currentValue >= 1 ? "✓" : "") : "\(Int(habit.currentValue)) \(habit.unit)")
                .font(Typography.statusValue)
        }
        .padding(.vertical, 8)
    }
}
