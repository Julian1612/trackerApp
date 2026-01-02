import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // 1. Heatmap Sektion (Oberes Drittel)
                HeatmapGridView(data: viewModel.heatmapData)
                    .frame(height: proxy.size.height * 0.33)
                
                // 2. Interaktions-Bereich direkt unter der Heatmap
                HStack {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(.black)
                            .padding(.leading, 20)
                    }
                    Spacer()
                }
                .padding(.top, 4) // Minimaler Abstand zur Heatmap
                .padding(.bottom, 8)
                
                // 3. Die Habit Liste beginnt direkt unter dem Plus
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.habits) { habit in
                            HabitRowView(habit: habit)
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
}
