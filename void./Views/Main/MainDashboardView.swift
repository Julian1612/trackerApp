import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Heatmap (Oberes Drittel)
            HeatmapGridView(data: viewModel.heatmapData)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.33)

            // Schwarzes Plus direkt unter der Heatmap
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
            .padding(.bottom, 8)

            // Dynamische Liste
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.habits) { habit in
                        HabitRowView(habit: habit, viewModel: viewModel)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $isShowingAddSheet) {
            AddHabitSheet(viewModel: viewModel)
        }
    }
}
