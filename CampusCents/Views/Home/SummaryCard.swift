import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState

    private var spentRatio: CGFloat {
        CGFloat(state.spent / max(state.total, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: greeting + health badge
            HStack(alignment: .center) {
                Text("Hi, \(state.profile.name)")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("Health \(state.healthScore)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Colors.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Colors.mint.opacity(0.2), in: Capsule())
            }
            .padding(.bottom, 16)

            // Hero: remaining amount + one clear progress ring
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(state.remaining.currency)
                        .font(.system(size: 32, weight: .bold))
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.12), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: 1 - spentRatio)
                        .stroke(
                            Colors.mint,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: 1 - spentRatio, to: 1)
                        .stroke(
                            Colors.rose.opacity(0.9),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(Int(spentRatio * 100))%")
                            .font(.system(size: 13, weight: .bold))
                        Text("used")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 72, height: 72)
            }
            .padding(.bottom, 16)

            // Income vs Spent: two clear metric blocks
            HStack(spacing: 10) {
                metricBlock(
                    title: "Income",
                    amount: state.profile.monthlyIncome,
                    icon: "arrow.down.circle.fill",
                    tint: Colors.mint
                )
                metricBlock(
                    title: "Spent",
                    amount: state.spent,
                    icon: "arrow.up.circle.fill",
                    tint: Colors.rose
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Colors.sky.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
    }

    private func metricBlock(title: String, amount: Double, icon: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(amount.currency)
                    .font(.subheadline.weight(.semibold))
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}
