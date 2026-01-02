import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit? // Für das Sheet beim Bearbeiten

    var body: some View {
        VStack(spacing: 0) {
            // Heatmap
            HeatmapGridView(data: viewModel.heatmapData)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.33)

            // Plus Button
            HStack {
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                }
                Spacer()
            }
            .padding(.top, 4)
            .padding(.bottom, 4)

            // Habit Liste mit Swipe Actions
            List {
                ForEach(viewModel.habits) { habit in
                    HabitRowView(habit: habit, viewModel: viewModel)
                        // Entfernt Standard-Padding der Liste für "engen" Look
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // SWIPE LEFT öffnet Bearbeiten statt Löschen
                            Button {
                                habitToEdit = habit
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            .tint(.black) // Minimalistisches Schwarz für die Action
                        }
                }
            }
            .listStyle(.plain) // Entfernt den grauen Hintergrund der Standard-Liste
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $isShowingAddSheet) {
            AddHabitSheet(viewModel: viewModel)
        }
        .sheet(item: $habitToEdit) { habit in
            AddHabitSheet(viewModel: viewModel, editingHabit: habit)
        }
    }
}
