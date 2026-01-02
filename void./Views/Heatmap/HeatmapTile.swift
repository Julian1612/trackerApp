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
        if score > 0 {
            // Wenn Score > 0: Zeige die Farbe (Graustufe) ohne Rahmen
            RoundedRectangle(cornerRadius: 3)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(ColorPalette.heatmapColor(for: score))
        } else {
            // Wenn KEINE Daten (0): Komplett Weiß 🤍
            // Mit einem minimalen Stroke (Rand), damit das Grid sichtbar bleibt
            RoundedRectangle(cornerRadius: 3)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1) // Sehr subtiler Rand
                )
        }
    }
}
