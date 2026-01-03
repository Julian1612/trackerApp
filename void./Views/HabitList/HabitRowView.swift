import SwiftUI

/// A single row in the habit list with particle/ripple effects on completion.
struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // UI State for gestures
    @State private var dragOffset: CGFloat = 0
    @State private var valueToAdd: Double = 0
    @State private var isDragging = false
    
    // 穴 Ripple Effect State
    @State private var showRipple = false
    
    // ✨ Motivation Sheet State
    @State private var isShowingMotivation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 倦 BACKGROUND ACTION LAYER
                if isDragging && habit.type == .value {
                    ZStack(alignment: .leading) {
                        ColorPalette.primary // Uses Black/White depending on mode
                            .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "plus")
                            Text("\(Int(valueToAdd)) \(habit.unit)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(ColorPalette.background) // Contrast text
                        .padding(.leading, 20)
                        .scaleEffect(isDragging ? 1.0 : 0.5)
                        .animation(.spring(), value: valueToAdd)
                    }
                }
                
                // 笞ｪｸFOREGROUND ROW
                HStack(spacing: 12) {
                    // Tap Button
                    Button(action: {
                        triggerHaptic()
                        handleTapIncrement()
                    }) {
                        HabitIconComponent(habit: habit)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(habit.title)
                            .font(Typography.habitTitle)
                            .foregroundColor(ColorPalette.primary)
                        Text(habit.category)
                            .font(Typography.categoryLabel)
                            .foregroundColor(ColorPalette.secondary)
                    }
                    
                    // ✨ Motivation Icon (Only if text exists)
                    if let motivation = habit.motivationText, !motivation.isEmpty {
                        Button(action: { isShowingMotivation = true }) {
                            Image(systemName: "text.quote") // Minimalist quote icon
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ColorPalette.secondary)
                                .frame(width: 30, height: 30)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain) // Prevents row tap conflict
                    }
                    
                    Spacer()
                    
                    // Status
                    if habit.type == .value {
                        Text("\(Int(habit.currentValue))/\(Int(habit.goalValue)) \(habit.unit)")
                            .font(Typography.statusValue)
                            .foregroundColor(ColorPalette.secondary)
                    } else if habit.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorPalette.primary)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(ColorPalette.background)
                .cornerRadius(12)
                // Shadow for depth
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .offset(x: dragOffset)
                
                // 穴 THE RIPPLE OVERLAY
                if showRipple {
                    Circle()
                        .fill(ColorPalette.primary.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(4) // Expands huge
                        .opacity(0) // Fades out
                        .position(x: 50, y: 30) // Starts from left
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard habit.type == .value else { return }
                        if gesture.translation.width > 0 {
                            isDragging = true
                            dragOffset = gesture.translation.width
                            calculateValueToAdd(width: geometry.size.width)
                        }
                    }
                    .onEnded { _ in
                        guard habit.type == .value else { return }
                        
                        if dragOffset > 50 {
                            commitProgress()
                        }
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = 0
                            isDragging = false
                            valueToAdd = 0
                        }
                    }
            )
        }
        .frame(height: 60)
        // ✨ Sheet presentation for motivation
        .sheet(isPresented: $isShowingMotivation) {
            if let text = habit.motivationText {
                MotivationView(text: text)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - Logic
    
    private func handleTapIncrement() {
        if habit.type == .checkmark {
            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : 1.0
            viewModel.updateHabitProgress(for: habit, value: newValue)
            if newValue == 1.0 { triggerSuccess() }
        } else {
            let newValue = habit.currentValue >= habit.goalValue ? 0.0 : habit.currentValue + 1.0
            viewModel.updateHabitProgress(for: habit, value: newValue)
            if newValue >= habit.goalValue { triggerSuccess() }
        }
    }
    
    private func commitProgress() {
        let newValue = habit.currentValue + valueToAdd
        viewModel.updateHabitProgress(for: habit, value: newValue)
        triggerSuccess()
    }
    
    private func calculateValueToAdd(width: CGFloat) {
        let progress = dragOffset / width
        let remaining = max(habit.goalValue - habit.currentValue, 0)
        
        if progress > 0.75 { valueToAdd = remaining }
        else if progress > 0.4 { valueToAdd = min(Double(dragOffset) / 5.0, remaining) }
        else { valueToAdd = min(Double(dragOffset) / 10.0, remaining) }
        
        valueToAdd = round(valueToAdd)
    }
    
    // MARK: - Effects
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func triggerSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Trigger Ripple Animation 穴
        withAnimation(.easeOut(duration: 0.5)) {
            showRipple = true
        }
        // Reset Ripple
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showRipple = false
        }
    }
}
