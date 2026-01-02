import SwiftUI

struct LogProgressSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    let habit: Habit
    
    @State private var valueToAdd: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Header-Vibe
            HStack {
                Text(habit.emoji).font(.system(size: 40))
                Text(habit.title).font(.title2).bold()
            }
            .padding(.top, 20)
            
            Divider()
            
            // Progress-Check
            VStack(spacing: 8) {
                Text("Aktueller Stand").font(.caption).foregroundColor(.gray)
                HStack(alignment: .lastTextBaseline) {
                    Text("\(Int(habit.currentValue))").font(.system(size: 34, weight: .bold))
                    Text("/ \(Int(habit.goalValue)) \(habit.unit)").font(.body).foregroundColor(.gray)
                }
            }
            
            // Input-Bereich für schnelle Gains
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Button(action: { if valueToAdd > 0 { valueToAdd -= 1 } }) {
                        Image(systemName: "minus.circle.fill").font(.title).foregroundColor(.gray.opacity(0.3))
                    }
                    
                    // Das $ ist hier beim Binding im TextField RICHTIG
                    TextField("0", value: $valueToAdd, format: .number)
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    Button(action: { valueToAdd += 1 }) {
                        Image(systemName: "plus.circle.fill").font(.title).foregroundColor(.black)
                    }
                }
                
                // Quick-Buttons für weniger Getippe
                HStack(spacing: 15) {
                    Button("+5") { valueToAdd += 5 }
                    Button("+10") { valueToAdd += 10 }
                    Button("Max") { valueToAdd = (habit.goalValue - habit.currentValue) }
                }
                .buttonStyle(.bordered).tint(.black)
            }
            .padding()
            
            Spacer()
            
            // Der Save-Move
            Button(action: {
                // 🔥 WICHTIG: Hier KEIN $ vor viewModel, sonst gibt's Error-Vibes!
                viewModel.logProgress(for: habit, value: valueToAdd)
                dismiss()
            }) {
                Text("Speichern")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.black).cornerRadius(12)
            }
            .padding(.horizontal).padding(.bottom, 20)
        }
        .presentationDetents([.medium]) // Macht das Sheet schön kompakt
    }
}
