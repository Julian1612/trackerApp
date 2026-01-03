import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    @State private var isShowingLogSheet = false

    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                if habit.type == .checkmark {
                    viewModel.logProgress(for: habit, value: habit.currentValue > 0 ? -1 : 1)
                } else {
                    isShowingLogSheet = true
                }
            }) {
                ZStack {
                    Circle().strokeBorder(Color.black, lineWidth: 1.5)
                    Text(habit.emoji)
                }
                .frame(width: 42, height: 42)
            }
            
            Text(habit.title)
                .font(.system(size: 17, weight: .medium))
            
            Spacer()
            
            Text("\(Int(habit.currentValue)) / \(Int(habit.goalValue)) \(habit.unit)")
                .font(.subheadline)
        }
        .padding(.vertical, 14)
        .sheet(isPresented: $isShowingLogSheet) {
            // 🔥 FIX: Wir übergeben viewModel und habit direkt.
            LogProgressSheet(viewModel: viewModel, habit: habit)
        }
    }
}
