import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    
    @State private var selectedCategory: String = "Alle"
    
    // Hilfs-Array für die Routine-Buttons
    let routines: [RoutineTime] = [.morning, .day, .evening, .any]

    var body: some View {
        VStack(spacing: 0) {
            // 1. Heatmap
            GeometryReader { proxy in
                HeatmapGridView(data: viewModel.heatmapData)
                    .frame(maxHeight: proxy.size.height * 0.33)
            }
            .frame(height: 300) // Provide a reasonable fixed container height; adjust as needed

            // 2. Toolbar-Bereich
            VStack(spacing: 12) {
                // A) NEU: Routine-Wahl (Morgen, Tag, Abend) - an der rot markierten Stelle
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(routines, id: \.self) { routine in
                            Button(action: {
                                withAnimation {
                                    viewModel.selectedRoutineTime = routine
                                    selectedCategory = "Alle" // Reset Kategorie bei Zeitwechsel
                                }
                            }) {
                                Text(routine.rawValue)
                                    .font(.system(size: 14, weight: viewModel.selectedRoutineTime == routine ? .bold : .medium))
                                    .foregroundColor(viewModel.selectedRoutineTime == routine ? .white : .black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        // Aktiver Tab ist schwarz, andere transparent mit Border
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
                .padding(.top, 10)

                // B) Bestehend: Plus + Kategorien (Unterkategorien)
                HStack(spacing: 12) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.black)
                            .padding(8)
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
                                            // Kategorie-Tabs sind jetzt dezenter (Grau/Weiß)
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

            // 3. Habit Liste (Doppelt gefiltert)
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
        // Beim App-Start (wenn die View erscheint) Zeit prüfen
        .onAppear {
            viewModel.determineCurrentRoutineTime()
        }
    }
}
