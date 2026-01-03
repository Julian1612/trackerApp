import SwiftUI

/// A single square in the activity heatmap.
struct HeatmapTile: View {
    let score: Double
    
    var body: some View {
        if score > 0 {
            // Display the grayscale intensity based on progress
            RoundedRectangle(cornerRadius: 3)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(ColorPalette.heatmapColor(for: score))
        } else {
            // Display an empty state tile with a subtle border
            RoundedRectangle(cornerRadius: 3)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }
}
