import SwiftUI

struct HabitIconComponent: View {
    let habit: Habit
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.primary, lineWidth: 1.2) // Minimalistischer Kreis
            
            // 🔥 FIX: Wir prüfen auf den neuen Typen .value
            // Der Fehler "ContinuousClock" verschwindet, wenn wir sauber auf HabitType prüfen
            if habit.type == HabitType.value {
                Circle() // Der Fortschritts-Ring für Dauer/Zähler
                    .trim(from: 0, to: CGFloat(habit.currentValue / habit.goalValue))
                    .stroke(ColorPalette.primary, lineWidth: 2.5)
                    .rotationEffect(.degrees(-90))
            }
            
            // Hier wird das individuelle Emoji angezeigt 🎯
            Text(habit.emoji)
                .font(.system(size: 16))
        }
        .frame(width: 36, height: 36)
    }
}
