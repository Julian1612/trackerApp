//
//  Typography.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

/// A centralized store for the app's typography.
/// Mixing System Sans-Serif with Serif for that "Editorial" high-end look.
struct Typography {
    // The "Art Gallery" Header Font 🎨
    static let headerSerif = Font.system(size: 32, weight: .bold, design: .serif)
    
    // Standard UI Fonts
    static let habitTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let categoryLabel = Font.system(size: 11, weight: .regular, design: .default)
    static let statusValue = Font.system(size: 13, weight: .medium, design: .monospaced)
    
    // Onboarding / Empty State Text
    static let quote = Font.system(size: 18, weight: .light, design: .serif).italic()
}
