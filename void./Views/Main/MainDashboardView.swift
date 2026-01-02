import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    
    @State private var selectedCategory: String = "Alle"
    
    // Nur Morgen, Tag, Abend - "Jederzeit" ist cancelled 🚫
    let routines: [RoutineTime] = [.morning, .day, .evening]

    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Header Area: Datum & Heatmap
            VStack(alignment: .leading, spacing: 12) {
                // 🛠 NEU: Das aktuelle Datum im fetten Header-Style
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE"))))
                    .font(.system(size: 24, weight: .bold))
                    .padding(.leading, 4) // Ein kleines bisschen Abstand vom Rand
                
                HeatmapGridView(data: viewModel.heatmapData)
                    .padding(.bottom, 10) // Luft nach unten zum Atmen
            }
            .padding(.horizontal) // Rand links/rechts
            .padding(.top, 20) // Ein bisschen Abstand zur Notch, damit es nicht klebt

            // 2. Toolbar-Bereich (Tabs & Filter)
            VStack(spacing: 12) {
                // A) Routine-Wahl (Morgen, Tag, Abend)
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
                                            .overlay(
                                                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }

                // B) Plus + Kategorien
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

            // 3. Habit Liste
            List {
                ForEach(viewModel.habits(for: selectedCategory)) { habit in
                    HabitRowView(habit: habit, viewModel: viewModel)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                habitToEdit = habit
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            .tint(.black)
                        }
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
        .onAppear {
            viewModel.determineCurrentRoutineTime()
        }
    }
}
