import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var isShowingAddSheet = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // Heatmap Sektion (Oberes Drittel)
                ScrollView(.vertical, showsIndicators: false) {
                    HeatmapGridView(data: viewModel.heatmapData)
                }
                .frame(height: proxy.size.height * 0.33)

                // Dezentes schwarzes Plus direkt unter der Heatmap
                HStack {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(.black) // Jetzt in Schwarz
                            .padding(.leading, 20)
                    }
                    Spacer()
                }
                .padding(.top, 5) // Höher platziert direkt unter der Heatmap
                .padding(.bottom, 10)

                // Habit Liste (Restliche zwei Drittel)
                // Wir nutzen ScrollView + ForEach für maximale Kontrolle über das Design
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.habits) { habit in
                            HabitRowView(habit: habit)
                                .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(ColorPalette.background.ignoresSafeArea())
            .sheet(isPresented: $isShowingAddSheet) {
                AddHabitSheet(viewModel: viewModel)
            }
        }
    }
}
