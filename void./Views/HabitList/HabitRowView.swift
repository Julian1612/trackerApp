import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // Wir brauchen hier kein Callback mehr für Gesten
    
    // Einfaches Haptic Feedback beim Tippen auf das Icon
    let impactHaptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(spacing: 15) {
            // 1. Interaktives Icon (Tippen zum Erledigen/Hochzählen)
            Button(action: {
                impactHaptic.impactOccurred()
                // Bei Checkmark: Toggle
                // Bei Dauer/Zähler: +1 (Standard-Inkrement)
                viewModel.incrementHabit(habit)
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 1.5)
                        .background(Circle().fill(Color.white))
                    
                    Text(habit.emoji)
                        .font(.system(size: 18))
                    
                    // Progress Ring
                    if habit.goalValue > 0 {
                        Circle()
                            .trim(from: 0, to: min(habit.currentValue / habit.goalValue, 1.0))
                            .stroke(Color.black, lineWidth: 3)
                            .rotationEffect(.degrees(-90))
                            .padding(2)
                    }
                }
                .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain) // Wichtig, damit nur der Button klickt

            // 2. Titel
            Text(habit.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // 3. Status Text (Rechts)
            if habit.type == .checkmark {
                if habit.currentValue >= 1 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 4) {
                    Text("\(Int(habit.currentValue))")
                        .fontWeight(.semibold)
                    Text("/ \(Int(habit.goalValue)) \(habit.unit)")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        // Keine Gesten mehr hier! Pure Stabilität.
    }
}
