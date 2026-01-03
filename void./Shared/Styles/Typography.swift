import SwiftUI

/// A centralized store for the app's typography
struct Typography {
    static let habitTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let categoryLabel = Font.system(size: 11, weight: .regular, design: .default)
    static let statusValue = Font.system(size: 13, weight: .medium, design: .monospaced)
}
