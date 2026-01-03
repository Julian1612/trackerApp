import SwiftUI

/// A single row in the habit list that supports tap actions and a special swipe-to-add gesture.
struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // UI State for the custom swipe gesture
    @State private var dragOffset: CGFloat = 0
    @State private var valueToAdd: Double = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 🌑 BACKGROUND (Action Layer)
                // Shown only when swiping to add progress
                if isDragging && habit.type == .value {
                    ZStack(alignment: .leading) {
                        Color.black // Dark vibe for the background action
                            .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "plus")
                            Text("\(Int(valueToAdd)) \(habit.unit)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .scaleEffect(isDragging ? 1.0 : 0.5)
                        .animation(.spring(), value: valueToAdd)
                    }
                }
                
                // ⚪️ FOREGROUND (The actual Habit Row)
                HStack(spacing: 12) {
                    // Icon Button for quick completion or +1 updates
                    Button(action: {
                        triggerHaptic()
                        if habit.type == .checkmark {
                            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : 1.0
                            viewModel.updateHabitProgress(for: habit, value: newValue)
                        } else {
                            // Quick increment for counter habits
                            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : habit.currentValue + 1.0
                            viewModel.updateHabitProgress(for: habit, value: newValue)
                        }
                    }) {
                        HabitIconComponent(habit: habit)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(habit.title)
                            .font(Typography.habitTitle)
                        Text(habit.category)
                            .font(Typography.categoryLabel)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status display on the right side
                    if habit.type == .value {
                        Text("\(Int(habit.currentValue))/\(Int(habit.goalValue)) \(habit.unit)")
                            .font(Typography.statusValue)
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
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Swipe-to-add only for 'value' habits
                            guard habit.type == .value else { return }
                            
                            if gesture.translation.width > 0 {
                                isDragging = true
                                dragOffset = gesture.translation.width
                                calculateValueToAdd(width: geometry.size.width)
                            }
                        }
                        .onEnded { _ in
                            guard habit.type == .value else { return }
                            
                            // Commit the progress if swiped far enough
                            if dragOffset > 50 {
                                let newValue = habit.currentValue + valueToAdd
                                viewModel.updateHabitProgress(for: habit, value: newValue)
                                triggerSuccessHaptic()
                            }
                            
                            // Reset position with a snappy animation
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragOffset = 0
                                isDragging = false
                                valueToAdd = 0
                            }
                        }
                )
            }
        }
        .frame(height: 60) // Maintain stability for GeometryReader
    }
    
    // MARK: - Gesture Logic
    
    /// Calculates how much to add based on the drag distance.
    private func calculateValueToAdd(width: CGFloat) {
        let progress = dragOffset / width
        let remaining = max(habit.goalValue - habit.currentValue, 0)
        
        if progress > 0.75 {
            // 🔥 Full Send: Almost swiped to the end -> fill the goal
            valueToAdd = remaining
        } else if progress > 0.4 {
            // 🚀 Turbo Mode: Faster increments
            let dynamicAdd = Double(dragOffset) / 5.0
            valueToAdd = min(dynamicAdd, remaining)
        } else {
            // 🚶‍♂️ Walk Mode: Precise small steps
            let steps = Double(dragOffset) / 10.0
            valueToAdd = min(steps, remaining)
        }
        
        valueToAdd = round(valueToAdd)
    }
    
    // MARK: - Haptics
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
