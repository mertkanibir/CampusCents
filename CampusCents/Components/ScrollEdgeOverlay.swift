import SwiftUI

struct ScrollEdgeOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    .init(color: Colors.scrollEdgeOverlayTop(for: colorScheme), location: 0),
                    .init(color: Colors.scrollEdgeOverlayTop(for: colorScheme).opacity(0.85), location: 0.25),
                    .init(color: Colors.scrollEdgeOverlayTop(for: colorScheme).opacity(0.35), location: 0.55),
                    .init(color: Colors.scrollEdgeOverlayTop(for: colorScheme).opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 128)
            .ignoresSafeArea(edges: .top)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
