import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState
    private let rowHeight: CGFloat = 68

    private var daysLeftInMonth: Int {
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        guard let startOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: startOfMonth),
              let lastDay = range.last else { return 1 }
        let todayDay = cal.component(.day, from: now)
        return max(1, lastDay - todayDay + 1)
    }

    private var dailyBudget: Double {
        state.remaining / Double(daysLeftInMonth)
    }

    private let rowSpacing: CGFloat = 6
    private let columnSpacing: CGFloat = 12
    private let cellPaddingH: CGFloat = 12
    private let cellPaddingV: CGFloat = 10
    private let lineSpacing: CGFloat = 2

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            HStack(alignment: .top, spacing: columnSpacing) {
                leftCell(
                    label: "\(daysLeftInMonth) days left",
                    value: "~\(dailyBudget.currency)/day",
                    valueFont: .system(size: 28, weight: .bold),
                    valueColor: Colors.mint
                )
                metricBlock(
                    title: "Income",
                    amount: state.profile.monthlyIncome,
                    tint: Colors.mint
                )
            }

            HStack(alignment: .top, spacing: columnSpacing) {
                leftCell(
                    label: "Remaining",
                    value: state.remaining.currency,
                    valueFont: .system(size: 32, weight: .bold),
                    valueColor: .primary
                )
                metricBlock(
                    title: "Spent",
                    amount: state.spent,
                    tint: Colors.rose
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
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

    private func leftCell(
        label: String,
        value: String,
        valueFont: Font,
        valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, cellPaddingH)
        .padding(.vertical, cellPaddingV)
        .frame(height: rowHeight)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func metricBlock(title: String, amount: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(amount.currency)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, cellPaddingH)
        .padding(.vertical, cellPaddingV)
        .frame(height: rowHeight)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.52), lineWidth: 1.1)
        )
    }

}
