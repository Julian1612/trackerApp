import SwiftUI

/// A centralized store for the app's color scheme
struct ColorPalette {
    static let background = Color(white: 1.0) // Pure White
    static let primary = Color(white: 0.0)    // Pure Black
    
    /// Returns the appropriate grayscale intensity based on the completion score
    /// - Parameter score: A value between 0.0 and 1.0
    static func heatmapColor(for score: Double) -> Color {
        let opacity: Double
        switch score {
        case 0..<0.2:
            opacity = 0.05
        case 0.2..<0.4:
            opacity = 0.25
        case 0.4..<0.7:
            opacity = 0.6
        default:
            opacity = 1.0
        }
        return primary.opacity(opacity)
    }
}
