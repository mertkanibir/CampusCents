import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi, \(state.profile.name)")
                        .font(.headline)
                    Text("Budget health score: \(state.healthScore)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                AvatarView(profile: state.profile, size: 40)
            }

            Text(state.remaining.currency)
                .font(.system(size: 28, weight: .bold))
            Text("Remaining this cycle")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ProgressView(value: state.spent / max(state.total, 1))
                .tint(Colors.mint)
                .controlSize(.small)

            HStack {
                Label("Income \(state.profile.monthlyIncome.currency)", systemImage: "arrow.down.circle.fill")
                    .font(.caption2)
                Spacer()
                Label("Spent \(state.spent.currency)", systemImage: "arrow.up.circle.fill")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ringSection(title: "Spent", value: state.spent, total: state.total, tint: Colors.rose)
                ringSection(title: "Remaining", value: state.remaining, total: state.total, tint: Colors.mint)
            }
            .padding(.top, 4)
        }
        .padding(14)
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
        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.25), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        tint,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(value.currency)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}
