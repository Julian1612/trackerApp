//
//  HeatmapTile.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct HeatmapTile: View {
    let score: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3) // Leicht abgerundete Ecken
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(ColorPalette.heatmapColor(for: score))
    }
}
