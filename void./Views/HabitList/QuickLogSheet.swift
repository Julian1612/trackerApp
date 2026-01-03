import SwiftUI

struct QuickLogSheet: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var valueToAdd: Double = 0

    var body: some View {
        VStack(spacing: 25) {
            // Header-Vibe
            Text("\(habit.emoji) \(habit.title)")
                .font(.title2)
                .bold()
            
            // Das dicke Eingabefeld
            HStack {
                TextField("Wert", value: $valueToAdd, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .bold))
            }
            
            // Quick-Adds für den Workflow
            HStack(spacing: 20) {
                Button("+5") { valueToAdd += 5 }
                Button("+10") { valueToAdd += 10 }
                Button("+20") { valueToAdd += 20 }
            }
            .buttonStyle(.bordered)
            
            // Der Save-Button, der endlich funktioniert
            Button(action: {
                // 🔥 FIXED: KEIN $ vor viewModel beim Aufruf der Funktion!
                // Wir nehmen den aktuellen Wert und addieren das Neue dazu
                let newValue = habit.currentValue + valueToAdd
                $viewModel.updateHabitProgress(for: habit, value: newValue)
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
