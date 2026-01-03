import SwiftUI

/// A grid view that displays a history of habit completion scores.
struct HeatmapGridView: View {
    let data: [Double]
    
    // 20 columns to show roughly 200 days of history
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 20)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<data.count, id: \.self) { index in
                HeatmapTile(score: data[index])
            }
        }
    }
}
