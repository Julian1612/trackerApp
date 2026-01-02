//
//  ColorPalette.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct ColorPalette {
    static let background = Color(white: 1.0) // #FFFFFF
    static let primary = Color(white: 0.0)    // #000000
    
    // Heatmap-Skala
    static func heatmapColor(for score: Double) -> Color {
        let opacity: Double
        switch score {
        case 0..<0.2: opacity = 0.05
        case 0.2..<0.4: opacity = 0.25
        case 0.4..<0.7: opacity = 0.6
        default: opacity = 1.0
        }
        return primary.opacity(opacity)
    }
}
