import SwiftUI

struct RecentTransactionsCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: TransactionHistoryView()) {
                HStack {
                    Text("Recent Activity")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if transactions.isEmpty {
                Text("No transactions yet. Tap + to add one.")
                    .foregroundStyle(colorScheme == .dark ? .secondary : Color.black.opacity(0.62))
                    .font(.subheadline)
            } else {
                ForEach(transactions.prefix(6)) { transaction in
                    TransactionRowView(transaction: transaction)
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
