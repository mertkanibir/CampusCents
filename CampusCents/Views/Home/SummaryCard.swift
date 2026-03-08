import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi, \(state.profile.name)")
                        .font(.title3.bold())
                    Text("Budget health score: \(state.healthScore)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                AvatarView(profile: state.profile, size: 50)
            }

            Text(state.remaining.currency)
                .font(.system(size: 36, weight: .bold))
            Text("Remaining this cycle")
                .font(.footnote)
                .foregroundStyle(.secondary)

            ProgressView(value: state.spent / max(state.total, 1))
                .tint(Colors.mint)

            HStack {
                Label("Income \(state.profile.monthlyIncome.currency)", systemImage: "arrow.down.circle.fill")
                    .font(.caption)
                Spacer()
                Label("Spent \(state.spent.currency)", systemImage: "arrow.up.circle.fill")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Divider()

            HStack(spacing: 0) {
                ringSection(title: "Spent", value: state.spent, total: state.total, tint: Colors.rose)
                Divider()
                    .frame(height: 70)
                ringSection(title: "Remaining", value: state.remaining, total: state.total, tint: Colors.mint)
            }
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
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(value / max(total, 1)))
                    .stroke(tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((value / max(total, 1)) * 100))%")
                    .font(.caption.bold())
            }
            .frame(width: 80, height: 80)

            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(value.currency)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
