//
//  ColorPalette.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

/// A centralized store for the app's color scheme.
/// Optimized for OLED True Black in Dark Mode.
struct ColorPalette {
    
    // MARK: - Core Colors
    
    // True Black for OLED vibes in Dark Mode 🌑
    static var background: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        })
    }
    
    static var primary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
    }
    
    static var secondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .lightGray : .darkGray
        })
    }
    
    // MARK: - Heatmap Logic
    
    /// Returns the appropriate grayscale intensity based on the completion score.
    static func heatmapColor(for score: Double) -> Color {
        let opacity: Double
        switch score {
        case 0..<0.2:
            opacity = 0.1 // A bit more visible for the aesthetic
        case 0.2..<0.4:
            opacity = 0.3
        case 0.4..<0.7:
            opacity = 0.6
        default:
            opacity = 1.0
        }
        return primary.opacity(opacity)
    }
    
    /// Cyberpunk Glow Effect for Dark Mode 💡
    static func glowColor(for score: Double) -> Color {
        // Only glow if there is significant progress
        if score > 0.4 {
            return primary.opacity(0.5)
        }
        return .clear
    }
}
