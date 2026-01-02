import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    @State private var habitToEdit: Habit?
    
    // State für den aktuell gewählten Tab (Standard: "Alle")
    @State private var selectedCategory: String = "Alle"

    var body: some View {
        VStack(spacing: 0) {
            // 1. Heatmap
            HeatmapGridView(data: viewModel.heatmapData)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.33)

            // 2. Toolbar: Plus-Button + Kategorie Tabs
            HStack(spacing: 12) {
                // Der Plus-Button (Links fixiert)
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.black)
                        .padding(10) // Größere Touch-Area
                        .background(Color.white)
                }
                
                // Die Tabs (Rechts scrollbar)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .font(.system(size: 13, weight: selectedCategory == category ? .bold : .medium))
                                    .foregroundColor(selectedCategory == category ? .white : .black)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == category ? Color.black : Color.gray.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.trailing, 20) // Padding rechts damit man den letzten Tab sieht
                }
            }
            .padding(.leading, 15) // Abstand vom linken Rand
            .padding(.top, 4)
            .padding(.bottom, 8)

            // 3. Habit Liste (Gefiltert)
            List {
                // Wir nutzen die Filter-Funktion aus dem ViewModel
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
    }
}
