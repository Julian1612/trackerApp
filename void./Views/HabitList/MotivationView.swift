import SwiftUI

/// A minimalist view to display affirmations or motivation text.
/// Supports basic Markdown (bullets, bold, etc.) and uses drag-to-dismiss.
struct MotivationView: View {
    let text: String
    
    var body: some View {
        ZStack {
            ColorPalette.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Little handle to indicate it's a sheet you can drag down
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                ScrollView {
                    // Using .init(text) forces SwiftUI to parse Markdown symbols
                    // like * for bullets or ** for bold.
                    Text(.init(text))
                        .font(.body) // Smaller font for better readability of long texts
                        .multilineTextAlignment(.leading) // Leading alignment looks better for lists
                        .foregroundColor(ColorPalette.primary)
                        .padding(.horizontal, 25)
                        // Ensure lists have enough space on the left
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(6)
                        .padding(.bottom, 30)
                }
            }
        }
    }
}
