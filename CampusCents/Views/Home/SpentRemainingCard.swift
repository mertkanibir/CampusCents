import SwiftUI

struct SpentRemainingCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 0) {
            ringSection(title: "Spent", value: state.spent, total: state.total, tint: Colors.rose)
            Divider()
                .frame(height: 80)
            ringSection(title: "Remaining", value: state.remaining, total: state.total, tint: Colors.mint)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Colors.sky.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }

    private func ringSection(title: String, value: Double, total: Double, tint: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(value / max(total, 1)))
                    .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((value / max(total, 1)) * 100))%")
                    .font(.subheadline.bold())
            }
            .frame(width: 110, height: 110)

            Text(title)
                .font(.headline)
            Text(value.currency)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
