import SwiftUI

struct QuickLogSheet: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var valueToAdd: Double = 0

    var body: some View {
        VStack(spacing: 25) {
            Text("\(habit.emoji) \(habit.title)").font(.title2).bold()
            
            HStack {
                TextField("Wert", value: $valueToAdd, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .bold))
            }
            
            HStack(spacing: 20) {
                Button("+5") { valueToAdd += 5 }
                Button("+10") { valueToAdd += 10 }
                Button("+20") { valueToAdd += 20 }
            }
            .buttonStyle(.bordered)
            
            Button(action: {
                // 🔥 FIXED: Auch hier das $ entfernt!
                $viewModel.updateHabitProgress(for: habit, value: habit.currentValue + valueToAdd)
                dismiss()
            }) {
                Text("Speichern")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
        }
        .padding()
        .presentationDetents([.medium])
    }
}
