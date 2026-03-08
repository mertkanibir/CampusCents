import SwiftUI

/// A dynamic gradient from recent activity categories that fades into the screen (Apple Card–inspired).
/// Shorter band that only passes the first card, with a soft vertical fade so there’s no hard edge.
struct ActivityGradientView: View {
    let colors: [Color]

    /// Softer, Apple Card–style: use up to 3 colors and blend gently so it’s not a harsh stripe.
    private var baseGradient: LinearGradient {
        let palette = colors.isEmpty ? [Colors.sky, Colors.lavender] : Array(colors.prefix(3))
        guard palette.count >= 2 else {
            let c = palette.first ?? Colors.sky
            return LinearGradient(
                colors: [c.opacity(0.85), c.opacity(0.5)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        let step = 1.0 / Double(max(1, palette.count - 1))
        let stops = palette.enumerated().map { i, color in
            Gradient.Stop(color: color.opacity(0.9), location: Double(i) * step)
        }
        return LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
    }

    /// Vertical mask: full opacity at top, transparent at bottom so it fades into the home screen.
    private var fadeMask: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black.opacity(0.5), location: 0.55),
                .init(color: .clear, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Rectangle()
            .fill(baseGradient)
            .mask(fadeMask)
            .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    VStack(spacing: 0) {
        ActivityGradientView(colors: [Colors.rose, Colors.peach, Colors.blueMint])
            .frame(height: 200)
        Spacer()
    }
}
