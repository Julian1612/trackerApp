import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    
    // "habitToLog" ist gelöscht 🗑️
    
    @State private var selectedCategory: String = "Alle"
    
    let routines: [RoutineTime] = [.morning, .day, .evening]

    var body: some View {
        VStack(spacing: 0) {
            
            // HEADER
            VStack(alignment: .leading, spacing: 12) {
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE"))))
                    .font(.system(size: 24, weight: .bold))
                    .padding(.leading, 16)
                    .padding(.top, 10)
                
                HeatmapGridView(data: viewModel.heatmapData)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
            .background(Color.white)

            // TOOLBAR
            VStack(spacing: 12) {
                // Routine Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(routines, id: \.self) { routine in
                            Button(action: {
                                withAnimation {
                                    viewModel.selectedRoutineTime = routine
                                    selectedCategory = "Alle"
                                }
                            }) {
                                Text(routine.rawValue)
                                    .font(.system(size: 14, weight: viewModel.selectedRoutineTime == routine ? .bold : .medium))
                                    .foregroundColor(viewModel.selectedRoutineTime == routine ? .white : .black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.selectedRoutineTime == routine ? Color.black : Color.white)
                                            .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Plus & Kategorien
                HStack(spacing: 12) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation { selectedCategory = category }
                                }) {
                                    Text(category)
                                        .font(.system(size: 13, weight: selectedCategory == category ? .bold : .medium))
                                        .foregroundColor(selectedCategory == category ? .black : .gray)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.gray.opacity(0.1) : Color.clear)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 15)
            .background(Color.white)

            // HABIT LISTE
            List {
                let currentHabits = viewModel.habits(for: selectedCategory)
                
                ForEach(currentHabits) { habit in
                    HabitRowView(habit: habit, viewModel: viewModel)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        
                        // Context Menu (Lange drücken) für Edit/Delete/Reset
                        .contextMenu {
                            Button {
                                habitToEdit = habit
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                viewModel.deleteHabit(habit)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.resetHabit(habit)
                            } label: {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                            }
                        }
                        // Kein Tap-Gesture mehr für das Log-Sheet!
                }
                .onMove { indices, newOffset in
                    viewModel.moveHabit(from: indices, to: newOffset, currentVisibleHabits: currentHabits)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.white.ignoresSafeArea())
        
        // SHEETS
        .sheet(isPresented: $isShowingAddSheet) {
            AddHabitSheet(viewModel: viewModel)
        }
        .sheet(item: $habitToEdit) { habit in
            AddHabitSheet(viewModel: viewModel, editingHabit: habit)
        }
        // Das LogProgressSheet ist hier entfernt 👋
        .onAppear {
            viewModel.determineCurrentRoutineTime()
        }
    }
}
