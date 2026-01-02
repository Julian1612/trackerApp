import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitListViewModel
    
    // Callback: Wenn "Edit" gedrückt wird, sag der MainView Bescheid
    var onEdit: () -> Void
    
    // State für die Geste
    @State private var offset: CGFloat = 0
    @State private var feedbackValue: Double = 0
    @State private var isMenuOpen: Bool = false
    
    let haptic = UIImpactFeedbackGenerator(style: .light)
    let buttonWidth: CGFloat = 70 // Breite pro Button

    var body: some View {
        ZStack {
            // 1. BACKGROUND LAYERS (Die Farben & Buttons dahinter)
            
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    // --- RECHTS SWIPEN (Slider / Check) ---
                    ZStack(alignment: .leading) {
                        if offset > 0 {
                            if habit.type == .checkmark {
                                Color.green
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.leading, 20)
                            } else {
                                // Slider Anzeige
                                Color.blue
                                HStack {
                                    Image(systemName: "plus")
                                    Text("\(Int(feedbackValue)) \(habit.unit)")
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(.leading, 20)
                                .offset(x: offset > 60 ? 0 : -20)
                            }
                        }
                    }
                    .frame(width: max(offset, 0))
                    
                    Spacer()
                    
                    // --- LINKS SWIPEN (Reset & Edit Buttons) ---
                    HStack(spacing: 0) {
                        // Reset Button (Orange)
                        Button(action: {
                            withAnimation {
                                viewModel.resetHabit(habit) // Setzt auf 0
                                offset = 0
                                isMenuOpen = false
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20))
                                Text("Reset")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: proxy.size.height)
                            .background(Color.orange)
                        }
                        
                        // Edit Button (Grau) -> Öffnet das Full Menu
                        Button(action: {
                            onEdit() // Trigger in MainView
                            // Menü schließen (optional direkt oder nach Rückkehr)
                            withAnimation {
                                offset = 0
                                isMenuOpen = false
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 20))
                                Text("Edit")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: proxy.size.height)
                            .background(Color.gray)
                        }
                    }
                    .frame(width: max(-offset, 0), alignment: .trailing)
                }
            }
            .background(Color.white)

            // 2. FOREGROUND (Der eigentliche Habit Inhalt)
            HStack(spacing: 12) {
                // Button / Icon
                Button(action: {
                    if habit.type == .checkmark {
                        viewModel.incrementHabit(habit)
                    }
                }) {
                    ZStack {
                        Circle().stroke(Color.black, lineWidth: 1)
                        Text(habit.emoji).font(.system(size: 16))
                        
                        if habit.goalValue > 0 {
                            Circle()
                                .trim(from: 0, to: min(habit.currentValue / habit.goalValue, 1.0))
                                .stroke(Color.black, lineWidth: 2.5)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    .frame(width: 38, height: 38)
                }
                .buttonStyle(PlainButtonStyle())

                Text(habit.title)
                    .font(Typography.habitTitle)
                
                Spacer()
                
                // Status Text
                if habit.type == .checkmark {
                    if habit.currentValue >= 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.black)
                    }
                } else {
                    HStack(spacing: 4) {
                        Text("\(Int(habit.currentValue))")
                            .bold()
                        Text("/ \(Int(habit.goalValue)) \(habit.unit)")
                            .foregroundColor(.gray)
                    }
                    .font(Typography.statusValue)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .offset(x: offset)
            // 3. GESTURE MAGIC
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Wenn Menü offen, ist Startpunkt versetzt
                        let startOffset = isMenuOpen ? -buttonWidth * 2 : 0
                        let currentTranslation = gesture.translation.width
                        let newOffset = startOffset + currentTranslation
                        
                        withAnimation(.interactiveSpring()) {
                            offset = newOffset
                            
                            // Logik für Slider (Rechts ziehen)
                            if offset > 0 && habit.type != .checkmark {
                                let stepPixels: CGFloat = 15 // Feinfühligkeit
                                let steps = Int(offset / stepPixels)
                                let newValue = Double(steps) * 1.0 // 1er Schritte
                                
                                if newValue != feedbackValue {
                                    if newValue > 0 { haptic.impactOccurred() }
                                    feedbackValue = newValue
                                }
                            }
                        }
                    }
                    .onEnded { gesture in
                        let translation = gesture.translation.width
                        
                        // Fall 1: Slider Commit (Rechts Swipe)
                        if offset > 80 && habit.type != .checkmark {
                            if feedbackValue > 0 {
                                withAnimation { viewModel.logProgress(for: habit, value: feedbackValue) }
                            }
                            withAnimation(.spring()) { offset = 0; feedbackValue = 0; isMenuOpen = false }
                        }
                        // Fall 2: Complete (Checkmark Rechts Swipe)
                        else if offset > 80 && habit.type == .checkmark {
                            withAnimation { viewModel.completeHabit(habit) }
                            withAnimation(.spring()) { offset = 0; isMenuOpen = false }
                        }
                        // Fall 3: Menü öffnen (Links Swipe)
                        // Wenn weit genug gezogen oder bereits offen und weiter gezogen
                        else if offset < -buttonWidth || (isMenuOpen && translation < 0) {
                            withAnimation(.spring()) {
                                offset = -buttonWidth * 2 // Öffnet für 2 Buttons Breite
                                isMenuOpen = true
                            }
                        }
                        // Fall 4: Zurücksnappen (Nicht weit genug)
                        else {
                            withAnimation(.spring()) {
                                offset = 0
                                feedbackValue = 0
                                isMenuOpen = false
                            }
                        }
                    }
            )
        }
        .contentShape(Rectangle()) // Macht die ganze Fläche touchable
    }
}
