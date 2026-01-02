import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    
    // Optional: Log Sheet für Taps
    @State private var habitToLog: Habit?
    
    @State private var selectedCategory: String = "Alle"
    
    let routines: [RoutineTime] = [.morning, .day, .evening]

    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE"))))
                    .font(.system(size: 24, weight: .bold))
                    .padding(.leading, 4)
                
                HeatmapGridView(data: viewModel.heatmapData)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Toolbar
            VStack(spacing: 12) {
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
                    .padding(.horizontal, 15)
                }

                HStack(spacing: 12) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(10)
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
                .padding(.horizontal, 15)
            }
            .padding(.bottom, 10)

            // List
            List {
                let currentHabits = viewModel.habits(for: selectedCategory)
                
                ForEach(currentHabits) { habit in
                    HabitRowView(
                        habit: habit,
                        viewModel: viewModel,
                        onEdit: {
                            // HIER: Öffnet das volle Bearbeitungs-Menü
                            // Da ist dann auch der Löschen-Button drin.
                            habitToEdit = habit
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    // Optional: Tap öffnet Log-Sheet
                    .onTapGesture {
                        if habit.type != .checkmark {
                            habitToLog = habit
                        } else {
                            viewModel.incrementHabit(habit)
                        }
                    }
                }
                .onMove { indices, newOffset in
                    viewModel.moveHabit(from: indices, to: newOffset, currentVisibleHabits: currentHabits)
                }
            }
            .listStyle(.plain)
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $isShowingAddSheet) {
            AddHabitSheet(viewModel: viewModel)
        }
        .sheet(item: $habitToEdit) { habit in
            AddHabitSheet(viewModel: viewModel, editingHabit: habit)
        }
        .sheet(item: $habitToLog) { habit in
            LogProgressSheet(viewModel: viewModel, habit: habit)
        }
        .onAppear {
            viewModel.determineCurrentRoutineTime()
        }
    }
}
