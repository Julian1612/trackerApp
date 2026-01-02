//
//  MainDashboardView.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI
import Combine

struct MainDashboardView: View {
    @StateObject private var viewModel = HabitListViewModel()
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 20)
    
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height
            VStack(spacing: 0) {
                // Heatmap Sektion (Oberes Drittel)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(0..<viewModel.heatmapData.count, id: \.self) { index in
                            HeatmapTile(score: viewModel.heatmapData[index])
                        }
                    }
                    .padding()
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
            .background(ColorPalette.background.ignoresSafeArea())
            .frame(width: proxy.size.width, height: totalHeight, alignment: .top)
        }
    }
}
