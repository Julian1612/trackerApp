import SwiftUI
struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var showingAddSheet = false // State für das Modal
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 20)
    
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height
            ZStack(alignment: .bottomTrailing) { // ZStack für den Button
                VStack(spacing: 0) {
                    // Heatmap (Oberes Drittel)
                    ScrollView(.vertical, showsIndicators: false) {
                        HeatmapGridView(data: viewModel.heatmapData)
                    }
                    .frame(height: totalHeight * 0.33)

                    // Habit Liste (Untere zwei Drittel)
                    List(viewModel.habits) { habit in
                        HabitRowView(habit: habit)
                            .listRowSeparator(.hidden)
                            .listRowBackground(ColorPalette.background)
                    }
                    .listStyle(.plain)
                    .frame(height: totalHeight * 0.67)
                }
                
                // Minimalistischer Plus-Button
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(24)
            }
            .background(ColorPalette.background.ignoresSafeArea())
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }
}
