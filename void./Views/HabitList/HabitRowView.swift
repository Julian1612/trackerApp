import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // Callback fürs Editieren
    var onEdit: () -> Void
    
    // MARK: - State
    @State private var offset: CGFloat = 0
    @State private var isMenuOpen: Bool = false
    @State private var feedbackValue: Double = 0
    
    // Constants
    let buttonWidth: CGFloat = 80
    let activationThreshold: CGFloat = 80
    let sliderStepWidth: CGFloat = 15
    let maxValuePerSwipe: Double = 120
    
    // MARK: - Haptic Engines (Crash-Proof 🛡️)
    let impactHaptic = UIImpactFeedbackGenerator(style: .light)       // Für Ticks
    let notificationHaptic = UINotificationFeedbackGenerator()      // Für Success/Warning

    var body: some View {
        ZStack {
            // 1. Background Layer (Farben & Buttons)
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    // --- RECHTS ZIEHEN (Slider / Check) ---
                    ZStack(alignment: .leading) {
                        if offset > 0 {
                            if habit.type == .checkmark {
                                Color.green
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.leading, 30)
                            } else {
                                Color.blue
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("\(Int(feedbackValue)) \(habit.unit)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .monospacedDigit()
                                }
                                .foregroundColor(.white)
                                .padding(.leading, 30)
                                .offset(x: offset > 100 ? 0 : -20)
                                .opacity(offset > 40 ? 1 : 0.5)
                            }
                        }
                    }
                    .frame(width: max(offset, 0))
                    .clipped()
                    
                    Spacer()
                    
                    // --- LINKS ZIEHEN (Menü: Reset & Edit) ---
                    HStack(spacing: 0) {
                        // RESET BUTTON
                        Button {
                            // 1. Wert nullen
                            viewModel.resetHabit(habit)
                            
                            // 2. Row schließen (animiert)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                isMenuOpen = false
                                feedbackValue = 0
                            }
                            
                            // 3. Feedback (Warning Type ist gut für Reset)
                            notificationHaptic.notificationOccurred(.warning)
                            
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title3)
                                Text("Reset")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: proxy.size.height)
                            .background(Color.orange)
                        }
                        
                        // EDIT BUTTON
                        Button {
                            // Erst schließen, dann Action
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                isMenuOpen = false
                            }
                            onEdit()
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "pencil")
                                    .font(.title3)
                                Text("Edit")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: proxy.size.height)
                            .background(Color.gray)
                        }
                    }
                    .frame(width: max(-offset, 0), alignment: .trailing)
                    .clipped()
                }
            }
            .background(Color(UIColor.systemGray6))

            // 2. Foreground Layer (Habit Inhalt)
            HStack(spacing: 15) {
                // Quick Tap Button
                Button(action: {
                    impactHaptic.impactOccurred()
                    if habit.type == .checkmark {
                        viewModel.incrementHabit(habit)
                    }
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(Color.black, lineWidth: 1.5)
                            .background(Circle().fill(Color.white))
                        Text(habit.emoji).font(.system(size: 18))
                        
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
                .buttonStyle(.plain)

                Text(habit.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                // Status Text
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
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onChanged { gesture in
                        handleDragChanged(gesture)
                    }
                    .onEnded { gesture in
                        handleDragEnded(gesture)
                    }
            )
        }
        // Tap im Hintergrund schließt Menü
        .background(
            Color.white.opacity(0.001).onTapGesture {
                if isMenuOpen { closeMenu() }
            }
        )
        // Listen-Styling entfernen für Rand-zu-Rand Swipe
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Logic Helpers
    
    private func closeMenu() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = 0
            isMenuOpen = false
            feedbackValue = 0
        }
    }
    
    private func handleDragChanged(_ gesture: DragGesture.Value) {
        let translation = gesture.translation.width
        var newOffset = translation + (isMenuOpen ? -buttonWidth * 2 : 0)
        
        // RECHTS SWIPE (Slider) - Nur wenn Menü zu ist
        if newOffset > 0 && !isMenuOpen {
            offset = newOffset
            
            if habit.type != .checkmark {
                let steps = Int(max(0, newOffset - 40) / sliderStepWidth)
                let newValue = min(Double(steps), maxValuePerSwipe)
                
                if newValue != feedbackValue {
                    impactHaptic.impactOccurred(intensity: 0.6)
                    feedbackValue = newValue
                }
            }
        }
        // LINKS SWIPE (Menü)
        else {
            // Begrenzung
            let maxMenuDrag = -(buttonWidth * 2 + 50)
            if newOffset < maxMenuDrag {
                newOffset = maxMenuDrag + (newOffset - maxMenuDrag) * 0.2
            }
            offset = newOffset
        }
    }
    
    private func handleDragEnded(_ gesture: DragGesture.Value) {
        // 1. Slider Commit
        if offset > activationThreshold && !isMenuOpen {
            if habit.type == .checkmark {
                viewModel.completeHabit(habit)
                notificationHaptic.notificationOccurred(.success)
            } else {
                if feedbackValue > 0 {
                    viewModel.logProgress(for: habit, value: feedbackValue)
                    notificationHaptic.notificationOccurred(.success)
                } else {
                    impactHaptic.impactOccurred(intensity: 0.3)
                }
            }
            closeMenu()
        }
        // 2. Menü öffnen
        else if offset < -buttonWidth {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offset = -buttonWidth * 2
                isMenuOpen = true
            }
            impactHaptic.impactOccurred(intensity: 0.5)
        }
        // 3. Reset
        else {
            closeMenu()
        }
    }
}
