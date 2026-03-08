import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
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

    private var isOverBudget: Bool {
        state.remaining < 0
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
                    valueColor: isOverBudget ? Colors.rose : (colorScheme == .dark ? Colors.mint : Colors.periwinkle)
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
                    valueColor: isOverBudget ? Colors.rose : .primary
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
                .fill(Colors.cardFill(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1.1)
                )
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.1), radius: 16, y: 8)
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
                .foregroundStyle(colorScheme == .dark ? Color.secondary : Color.primary.opacity(0.72))
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
                .fill(Colors.metricFill(tint, scheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Colors.metricStroke(tint, scheme: colorScheme), lineWidth: 1.1)
        )
    }

}
