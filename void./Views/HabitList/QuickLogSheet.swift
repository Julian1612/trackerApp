import SwiftUI

struct QuickLogSheet: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var valueToAdd: Double = 0

    var body: some View {
        VStack(spacing: 30) {
            // Header: Emoji & Titel
            VStack(spacing: 8) {
                Text(habit.emoji)
                    .font(.system(size: 50))
                Text(habit.title)
                    .font(.headline)
            }
            .padding(.top)
            
            // Value Input
            VStack(spacing: 15) {
                HStack(alignment: .lastTextBaseline) {
                    TextField("0", value: $valueToAdd, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                    
                    Text(habit.unit)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Quick Add Pills
                HStack(spacing: 12) {
                    ForEach([1, 5, 10], id: \.self) { amount in
                        Button(action: { valueToAdd += Double(amount) }) {
                            Text("+\(amount)")
                                // 🔥 FIX: Hier war der Syntax-Fehler.
                                // Korrekt ist: .font(.subheadline.weight(.medium))
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Save Button
            Button(action: {
                let newValue = habit.currentValue + valueToAdd
                viewModel.updateHabitProgress(for: habit, value: newValue)
                dismiss()
            }) {
                Text("Speichern")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
