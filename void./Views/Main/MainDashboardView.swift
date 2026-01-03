import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// The root view of the app.
/// Now features the "Void" aesthetic with Serif fonts and True Black background support.
struct MainDashboardView: View {
    // 🔥 SwiftData Context Injection
    // This allows the view to access the database context provided by VoidApp.swift
    @Environment(\.modelContext) private var modelContext
    
    // ViewModel as StateObject (The Brain)
    // Manages the entire state of the habit list and heatmap logic
    @StateObject private var viewModel = HabitListViewModel()
    
    // UI State Management
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    @State private var selectedCategory: String = "All"
    
    // Drag & Drop State
    @State private var draggedHabit: Habit?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 🌑 Global Background (True Black in Dark Mode)
                // Ignores safe area to cover the entire screen including notch/dynamic island
                ColorPalette.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header & Heatmap Section
                    VStack(alignment: .leading, spacing: 16) {
                        // ✍️ Editorial Serif Font for the Date
                        // Gives the app a high-end magazine feel
                        Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(Typography.headerSerif)
                            .foregroundColor(ColorPalette.primary)
                            .padding(.horizontal, 16)
                        
                        // The visual representation of consistency
                        HeatmapGridView(data: viewModel.heatmapData)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)

                    // MARK: - Filter Toolbar
                    VStack(spacing: 12) {
                        // 1. Time of Day Filter (Morning, Day, Evening)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(RoutineTime.allCases) { routine in
                                    Button(action: {
                                        withAnimation {
                                            viewModel.selectedRoutineTime = routine
                                            selectedCategory = "All" // Reset category when changing time
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

                        // 2. Category Filter & Add Button
                        HStack(spacing: 12) {
                            // The "Add New Habit" Button
                            Button(action: { isShowingAddSheet = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(ColorPalette.primary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle().stroke(ColorPalette.primary.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            // Scrollable Category List
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

                    // MARK: - Habit List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            let habits = viewModel.habits(for: selectedCategory)
                            
                            if habits.isEmpty {
                                // 👻 Empty State with Vibes (The "Void" Aesthetic)
                                VStack(spacing: 10) {
                                    Text("The void is empty.")
                                        .font(Typography.quote)
                                        .foregroundColor(Color.gray)
                                    Text("Start creating your reality.")
                                        .font(.caption)
                                        .foregroundColor(Color.gray.opacity(0.6))
                                }
                                .padding(.top, 50)
                            } else {
                                // List Items
                                ForEach(habits) { habit in
                                    HabitRowView(habit: habit, viewModel: viewModel)
                                        .padding(.horizontal, 16)
                                        .contextMenu {
                                            // Context Menu for quick actions
                                            Button { habitToEdit = habit } label: { Label("Edit", systemImage: "pencil") }
                                            Button { viewModel.updateHabitProgress(for: habit, value: 0) } label: { Label("Reset", systemImage: "arrow.counterclockwise") }
                                            Button(role: .destructive) { viewModel.deleteHabit(habit) } label: { Label("Delete", systemImage: "trash") }
                                        }
                                        // Drag & Drop Modifiers
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
        // 🧠 Inject Context into ViewModel on Appear
        // This connects the UI to the Database
        .onAppear { viewModel.setContext(modelContext) }
        
        // Sheets (Modals)
        .sheet(isPresented: $isShowingAddSheet) { AddHabitSheet(viewModel: viewModel) }
        .sheet(item: $habitToEdit) { habit in AddHabitSheet(viewModel: viewModel, editingHabit: habit) }
    }
}

// MARK: - Drag & Drop Delegate

/// Handles the logic for reordering habits via drag and drop.
/// Now compatible with the Class-based Habit model (SwiftData).
struct HabitDropDelegate: DropDelegate {
    let item: Habit
    var viewModel: HabitListViewModel
    @Binding var draggedHabit: Habit?

    /// Called when the dragged item enters a new position.
    func dropEntered(info: DropInfo) {
        // Ensure we are dragging a valid habit and not dropping it on itself
        guard let draggedHabit = draggedHabit,
              draggedHabit.id != item.id,
              let from = viewModel.habits.firstIndex(where: { $0.id == draggedHabit.id }),
              let to = viewModel.habits.firstIndex(where: { $0.id == item.id })
        else { return }

        // Perform the move animation if the position has changed
        if from != to {
            withAnimation {
                viewModel.moveHabit(from: draggedHabit.id, to: item.id)
            }
        }
    }

    /// Tells the system that we are performing a 'move' operation.
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    /// Finalizes the drop action.
    func performDrop(info: DropInfo) -> Bool {
        self.draggedHabit = nil
        return true
    }
}
