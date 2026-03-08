import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState
    
    private var spentRatio: Int {
        Int((state.spent / max(state.total, 1)) * 100)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(state.remaining.currency)
                        .font(.system(size: 30, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .contentTransition(.numericText())
                }

                HStack(spacing: 8) {
                    chip(text: "Health \(state.healthScore)", tint: Colors.mint, fillOpacity: 0.28)
                    chip(text: "Used \(spentRatio)%", tint: Colors.rose, fillOpacity: 0.24)
                }

                metricBlock(
                    title: "Budget",
                    amount: state.total,
                    tint: Colors.periwinkle
                )
                .frame(width: 156, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 7) {
                metricBlock(
                    title: "Income",
                    amount: state.profile.monthlyIncome,
                    tint: Colors.mint
                )
                metricBlock(
                    title: "Spent",
                    amount: state.spent,
                    tint: Colors.rose
                )
            }
            .frame(width: 156)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Colors.sky.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
    }

    private func metricBlock(title: String, amount: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(amount.currency)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(height: 68)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.52), lineWidth: 1.1)
        )
    }

    private func chip(text: String, tint: Color, fillOpacity: Double) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(tint.opacity(fillOpacity), in: Capsule())
    }
}
