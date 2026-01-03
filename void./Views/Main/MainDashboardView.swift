import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    @State private var selectedCategory: String = "Alle"
    
    var body: some View {
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
                    .padding(.horizontal, 16)
                }

                HStack(spacing: 12) {
                    // Das dezente schwarze Plus
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
            List {
                let currentHabits = viewModel.habits(for: selectedCategory)
                ForEach(currentHabits) { habit in
                    HabitRowView(habit: habit, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        // 🔥 FIX: Insets anpassen, um die Rows näher zusammen zu rücken
                        // Top/Bottom auf 4 reduziert
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .contextMenu {
                            Button { habitToEdit = habit } label: { Label("Bearbeiten", systemImage: "pencil") }
                            Button { viewModel.updateHabitProgress(for: habit, value: 0) } label: { Label("Reset", systemImage: "arrow.counterclockwise") }
                        }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $isShowingAddSheet) { AddHabitSheet(viewModel: viewModel) }
        .sheet(item: $habitToEdit) { habit in AddHabitSheet(viewModel: viewModel, editingHabit: habit) }
    }
}
