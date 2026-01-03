import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HabitListViewModel()
    
    // UI State
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    @State private var selectedCategory: String = "All"
    
    // Drag & Drop
    @State private var draggedHabit: Habit?
    
    // ✨ Animation State for Empty View
    @State private var isBreathing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header & Heatmap
                    VStack(alignment: .leading, spacing: 16) {
                        Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(Typography.headerSerif)
                            .foregroundColor(ColorPalette.primary)
                            .padding(.horizontal, 16)
                        
                        HeatmapGridView(data: viewModel.heatmapData)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)

                    // MARK: - Filter Toolbar
                    VStack(spacing: 12) {
                        // Time Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(RoutineTime.allCases) { routine in
                                    Button(action: {
                                        withAnimation {
                                            viewModel.selectedRoutineTime = routine
                                            selectedCategory = "All"
                                        }
                                    }) {
                                        Text(routine.rawValue)
                                            .font(.system(size: 14, weight: viewModel.selectedRoutineTime == routine ? .bold : .medium))
                                            .foregroundColor(viewModel.selectedRoutineTime == routine ? ColorPalette.background : ColorPalette.primary)
                                            .padding(.vertical, 8).padding(.horizontal, 16)
                                            .background(
                                                Capsule()
                                                    .fill(viewModel.selectedRoutineTime == routine ? ColorPalette.primary : Color.clear)
                                                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // Category Filter & Add
                        HStack(spacing: 12) {
                            Button(action: { isShowingAddSheet = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(ColorPalette.primary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle().stroke(ColorPalette.primary.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.categories, id: \.self) { cat in
                                        Button(action: { withAnimation { selectedCategory = cat } }) {
                                            Text(cat)
                                                .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                                                .foregroundColor(selectedCategory == cat ? ColorPalette.background : Color.gray)
                                                .padding(.vertical, 6).padding(.horizontal, 12)
                                                .background(Capsule().fill(selectedCategory == cat ? ColorPalette.primary : Color.clear))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)

                    // MARK: - Habit List / Alive Empty State
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            // 🚨 FIX: Call the renamed function 'getVisibleHabits'
                            let habits = viewModel.getVisibleHabits(for: selectedCategory)
                            
                            if habits.isEmpty {
                                // 👻 ALIVE EMPTY STATE 👻
                                VStack(spacing: 25) {
                                    Spacer().frame(height: 40)
                                    
                                    // Abstract Breathing Shape
                                    ZStack {
                                        Circle()
                                            .fill(ColorPalette.primary.opacity(0.05))
                                            .frame(width: 120, height: 120)
                                            .scaleEffect(isBreathing ? 1.1 : 0.9)
                                            .blur(radius: 20)
                                        
                                        Circle()
                                            .stroke(ColorPalette.primary.opacity(0.2), lineWidth: 1)
                                            .frame(width: 80, height: 80)
                                            .scaleEffect(isBreathing ? 1.05 : 0.95)
                                    }
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                            isBreathing = true
                                        }
                                    }
                                    
                                    Text("The void awaits your input.")
                                        .font(Typography.quote)
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                        .opacity(0.8)
                                }
                                .padding(.top, 20)
                            } else {
                                // List Items
                                ForEach(habits) { habit in
                                    HabitRowView(habit: habit, viewModel: viewModel)
                                        .padding(.horizontal, 16)
                                        .contextMenu {
                                            Button { habitToEdit = habit } label: { Label("Edit", systemImage: "pencil") }
                                            Button { viewModel.updateHabitProgress(for: habit, value: 0) } label: { Label("Reset", systemImage: "arrow.counterclockwise") }
                                            Button(role: .destructive) { viewModel.deleteHabit(habit) } label: { Label("Delete", systemImage: "trash") }
                                        }
                                        .onDrag {
                                            self.draggedHabit = habit
                                            return NSItemProvider(object: habit.id.uuidString as NSString)
                                        }
                                        .onDrop(of: [UTType.text], delegate: HabitDropDelegate(item: habit, viewModel: viewModel, draggedHabit: $draggedHabit))
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear { viewModel.setContext(modelContext) }
        .sheet(isPresented: $isShowingAddSheet) { AddHabitSheet(viewModel: viewModel) }
        .sheet(item: $habitToEdit) { habit in AddHabitSheet(viewModel: viewModel, editingHabit: habit) }
    }
}

// 🚨 FIX: HabitDropDelegate restored!
struct HabitDropDelegate: DropDelegate {
    let item: Habit
    var viewModel: HabitListViewModel
    @Binding var draggedHabit: Habit?

    func dropEntered(info: DropInfo) {
        guard let draggedHabit = draggedHabit,
              draggedHabit.id != item.id,
              let from = viewModel.habits.firstIndex(where: { $0.id == draggedHabit.id }),
              let to = viewModel.habits.firstIndex(where: { $0.id == item.id })
        else { return }

        if from != to {
            withAnimation {
                viewModel.moveHabit(from: draggedHabit.id, to: item.id)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.draggedHabit = nil
        return true
    }
}
