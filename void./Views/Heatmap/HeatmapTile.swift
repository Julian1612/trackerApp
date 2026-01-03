//
//  HeatmapTile.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

/// A single square in the activity heatmap.
/// Now features micro-interactions (Bounce) and Glow effects.
struct HeatmapTile: View {
    let score: Double
    
    @State private var isPressed = false
    @State private var showScore = false
    
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
            
            // Minimal Overlay for Score (optional micro-interaction)
            if showScore && score > 0 {
                Text("\(Int(score * 100))%")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .transition(.opacity)
            }
        }
        // Micro-Interaction: Bounce on Tap 🏀
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            guard score > 0 else { return }
            triggerHaptic()
            isPressed = true
            showScore = true
            
            // Reset after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showScore = false }
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
