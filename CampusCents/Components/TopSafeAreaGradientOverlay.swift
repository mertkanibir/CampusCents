import SwiftUI

struct TopSafeAreaGradientOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Colors.backgroundTop(for: colorScheme), Colors.backgroundTop(for: colorScheme).opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .ignoresSafeArea(edges: .top)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
