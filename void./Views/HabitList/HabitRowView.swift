import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // UI State für Swipe-Gesten
    @State private var dragOffset: CGFloat = 0
    @State private var valueToAdd: Double = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 🌑 HINTERGRUND (Action Layer)
                // Zeigt an, was passiert, wenn man swiped
                if isDragging && habit.type == .value {
                    ZStack(alignment: .leading) {
                        Color.black // Schwarzer Background beim Swipen
                            .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "plus")
                            Text("\(Int(valueToAdd)) \(habit.unit)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .scaleEffect(isDragging ? 1.0 : 0.5) // Leichte Pop-Animation
                        .animation(.spring(), value: valueToAdd)
                    }
                }
                
                // ⚪️ VORDERGRUND (Die eigentliche Row)
                HStack(spacing: 12) {
                    // Icon Button (Klickbar für schnelle +1 oder Check)
                    Button(action: {
                        triggerHaptic()
                        if habit.type == .checkmark {
                            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : 1.0
                            viewModel.updateHabitProgress(for: habit, value: newValue)
                        } else {
                            // Bei Anzahl: Tap erhöht einfach um 1 (für kleine Updates)
                            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : habit.currentValue + 1.0
                            viewModel.updateHabitProgress(for: habit, value: newValue)
                        }
                    }) {
                        HabitIconComponent(habit: habit)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(habit.title)
                            .font(.system(size: 16, weight: .semibold))
                        Text(habit.category)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Anzeige rechts
                    if habit.type == .value {
                        Text("\(Int(habit.currentValue))/\(Int(habit.goalValue)) \(habit.unit)")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else if habit.currentValue >= habit.goalValue {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(12)
                .offset(x: dragOffset) // 🔥 Hier passiert die Magie
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Feature nur für .value Habits aktivieren
                            guard habit.type == .value else { return }
                            
                            // Nur nach rechts swipen erlauben
                            if gesture.translation.width > 0 {
                                isDragging = true
                                dragOffset = gesture.translation.width
                                calculateValueToAdd(width: geometry.size.width)
                            }
                        }
                        .onEnded { _ in
                            guard habit.type == .value else { return }
                            
                            // Wenn weit genug geswiped wurde, Wert speichern
                            if dragOffset > 50 {
                                let newValue = habit.currentValue + valueToAdd
                                viewModel.updateHabitProgress(for: habit, value: newValue)
                                triggerSuccessHaptic()
                            }
                            
                            // Reset Animation
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragOffset = 0
                                isDragging = false
                                valueToAdd = 0
                            }
                        }
                )
            }
        }
        .frame(height: 60) // Fixe Höhe für GeometryReader Stabilität
    }
    
    // 🧠 Die Logik für die dynamische Beschleunigung
    private func calculateValueToAdd(width: CGFloat) {
        let progress = dragOffset / width
        let remaining = max(habit.goalValue - habit.currentValue, 0)
        
        if progress > 0.75 {
            // 🔥 Full Send: Wenn man fast am Rand ist -> Ziel füllen
            valueToAdd = remaining
        } else if progress > 0.4 {
            // 🚀 Turbo Mode: Schnellere Erhöhung
            // Mapping: 40% bis 75% Screen-Width mapt auf 10 bis 50% vom Zielwert (oder statisch schneller)
            let dynamicAdd = Double(dragOffset) / 5.0
            valueToAdd = min(dynamicAdd, remaining)
        } else {
            // 🚶‍♂️ Walk Mode: Präzise kleine Schritte (1...10)
            let steps = Double(dragOffset) / 10.0
            valueToAdd = min(steps, remaining)
        }
        
        // Runden, damit wir keine krummen Zahlen wie 1.43 haben
        valueToAdd = round(valueToAdd)
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
