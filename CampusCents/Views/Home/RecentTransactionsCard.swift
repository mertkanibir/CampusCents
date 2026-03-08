import SwiftUI

struct RecentTransactionsCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.headline.weight(.semibold))

            if transactions.isEmpty {
                Text("No transactions yet. Tap + to add one.")
                    .foregroundStyle(colorScheme == .dark ? .secondary : Color.black.opacity(0.62))
                    .font(.subheadline)
            } else {
                ForEach(transactions.prefix(6)) { transaction in
                    HStack(spacing: 10) {
                        Image(systemName: transaction.category.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(
                                LinearGradient(
                                    colors: [
                                        transaction.category.tint.opacity(0.95),
                                        transaction.category.tint
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(.white.opacity(0.24), lineWidth: 1)
                            }
                            .shadow(color: transaction.category.tint.opacity(0.35), radius: 10, y: 5)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.title)
                                .font(.subheadline.weight(.semibold))
                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? .secondary : Color.black.opacity(0.58))
                        }
                        Spacer()
                        Text(transaction.amount.currency)
                            .font(.subheadline.bold())
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            state.deleteTransaction(transaction)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding()
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 14, y: 8)
    }
}
