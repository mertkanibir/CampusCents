import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hi, \(state.profile.name)")
                    .font(.headline)
                Text("Budget health score: \(state.healthScore)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(state.remaining.currency)
                .font(.system(size: 26, weight: .bold))
            Text("Remaining this cycle")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ProgressView(value: state.spent / max(state.total, 1))
                .tint(Colors.mint)
                .controlSize(.small)

            HStack(alignment: .center, spacing: 8) {
                Label("Income \(state.profile.monthlyIncome.currency)", systemImage: "arrow.down.circle.fill")
                    .font(.caption2)
                Spacer(minLength: 4)
                HStack(spacing: 6) {
                    ringSection(title: "Spent", value: state.spent, total: state.total, tint: Colors.rose)
                    ringSection(title: "Remaining", value: state.remaining, total: state.total, tint: Colors.mint)
                }
                Spacer(minLength: 4)
                Label("Spent \(state.spent.currency)", systemImage: "arrow.up.circle.fill")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Colors.sky.opacity(0.35), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }

    private func ringSection(title: String, value: Double, total: Double, tint: Color) -> some View {
        let progress = value / max(total, 1)
        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.25), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 36, height: 36)
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(width: 44)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}
