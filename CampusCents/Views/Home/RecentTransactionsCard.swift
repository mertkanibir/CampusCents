import SwiftUI

struct RecentTransactionsCard: View {
    @EnvironmentObject var state: AppState
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.headline)

            if transactions.isEmpty {
                Text("No transactions yet. Tap + to add one.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(transactions.prefix(6)) { transaction in
                    HStack(spacing: 10) {
                        Image(systemName: transaction.category.icon)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(transaction.category.tint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.title)
                                .font(.subheadline)
                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
