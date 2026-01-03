import SwiftUI

/// A sheet that allows users to manually log progress for a specific habit.
struct LogProgressSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    let habit: Habit
    @State private var valueToAdd: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("\(habit.emoji) \(habit.title)")
                .font(.title2)
                .bold()
                .padding(.top, 20)
            
            VStack(spacing: 20) {
                TextField("Value", value: $valueToAdd, format: .number)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                
                HStack {
                    Button("+5") { valueToAdd += 5 }
                    Button("+10") { valueToAdd += 10 }
                    Button("Max") { valueToAdd = (habit.goalValue - habit.currentValue) }
                }
                .buttonStyle(.bordered)
                .tint(.black)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.logProgress(for: habit, value: valueToAdd)
                dismiss()
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}
