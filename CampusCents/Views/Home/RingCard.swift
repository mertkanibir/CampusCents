import SwiftUI

struct RingCard: View {
    let title: String
    let value: Double
    let total: Double
    let tint: Color

    var body: some View {
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
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
