import SwiftUI

/// A reusable component that displays the habit's emoji and a progress ring.
struct HabitIconComponent: View {
    let habit: Habit
    
    var body: some View {
        ZStack {
            // Minimalist outer circle
            Circle()
                .stroke(ColorPalette.primary, lineWidth: 1.2)
            
            // Progress ring: only shown for 'value' based habits
            if habit.type == .value {
                Circle()
                    .trim(from: 0, to: CGFloat(min(habit.currentValue / habit.goalValue, 1.0)))
                    .stroke(ColorPalette.primary, lineWidth: 2.5)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: habit.currentValue)
            }
            
            // The emoji representing the habit
            Text(habit.emoji)
                .font(.system(size: 16))
        }
        .frame(width: 36, height: 36)
    }
}
