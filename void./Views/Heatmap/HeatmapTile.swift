import SwiftUI

/// A single square in the activity heatmap.
/// Pure aesthetic. No interactions. Just vibes. 🌑
struct HeatmapTile: View {
    let score: Double
    
    // Environment check for Dark Mode logic
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if score > 0 {
                // Active Tile with Glow ✨
                RoundedRectangle(cornerRadius: 4)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(ColorPalette.heatmapColor(for: score))
                    // The "Void" Glow - only in Dark Mode and for high scores
                    .shadow(color: colorScheme == .dark ? ColorPalette.glowColor(for: score) : .clear, radius: 4, x: 0, y: 0)
            } else {
                // Empty State
                RoundedRectangle(cornerRadius: 4)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(ColorPalette.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            }
        }
    }
}
