import SwiftUI
import UniformTypeIdentifiers

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    @State private var selectedCategory: String = "Alle"
    
    // State für das Drag & Drop Item
    @State private var draggedHabit: Habit?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header & Heatmap
                VStack(alignment: .leading, spacing: 12) {
                    Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE"))))
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal, 16)
                    HeatmapGridView(data: viewModel.heatmapData)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 10)

                // Toolbar mit Routinen & Kategorien
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(RoutineTime.allCases) { routine in
                                Button(action: {
                                    withAnimation {
                                        viewModel.selectedRoutineTime = routine
                                        selectedCategory = "Alle"
                                    }
                                }) {
                                    Text(routine.rawValue)
                                        .font(.system(size: 14, weight: viewModel.selectedRoutineTime == routine ? .bold : .medium))
                                        .foregroundColor(viewModel.selectedRoutineTime == routine ? .white : .black)
                                        .padding(.vertical, 8).padding(.horizontal, 16)
                                        .background(Capsule().fill(viewModel.selectedRoutineTime == routine ? Color.black : Color.white).overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    HStack(spacing: 12) {
                        Button(action: { isShowingAddSheet = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.categories, id: \.self) { cat in
                                    Button(action: { withAnimation { selectedCategory = cat } }) {
                                        Text(cat).font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                                            .foregroundColor(selectedCategory == cat ? .black : .gray)
                                            .padding(.vertical, 6).padding(.horizontal, 12)
                                            .background(Capsule().fill(selectedCategory == cat ? Color.gray.opacity(0.1) : Color.clear))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 15)

                // Liste der Habits
                ScrollView {
                    LazyVStack(spacing: 0) { // LazyVStack statt List für besseres Custom Drag&Drop Handling
                         ForEach(viewModel.habits(for: selectedCategory)) { habit in
                            HabitRowView(habit: habit, viewModel: viewModel)
                                .padding(.vertical, 4) // Spacing direkt hier
                                .padding(.horizontal, 16)
                                .contextMenu {
                                    Button { habitToEdit = habit } label: { Label("Bearbeiten", systemImage: "pencil") }
                                    Button { viewModel.updateHabitProgress(for: habit, value: 0) } label: { Label("Reset", systemImage: "arrow.counterclockwise") }
                                }
                                // 🌑 DRAG & DROP START
                                .onDrag {
                                    self.draggedHabit = habit
                                    return NSItemProvider(object: habit.id.uuidString as NSString)
                                }
                                .onDrop(of: [UTType.text], delegate: HabitDropDelegate(item: habit, viewModel: viewModel, draggedHabit: $draggedHabit))
                                // 🌑 DRAG & DROP ENDE
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) { AddHabitSheet(viewModel: viewModel) }
        .sheet(item: $habitToEdit) { habit in AddHabitSheet(viewModel: viewModel, editingHabit: habit) }
    }
}

// 🔥 Der Delegate: Jetzt mit dropUpdated!
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

    // 🔥 WICHTIG: Das hier hat gefehlt. Es sagt dem System: "Ja, wir verschieben!"
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.draggedHabit = nil
        return true
    }
}
