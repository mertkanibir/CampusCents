import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
}
