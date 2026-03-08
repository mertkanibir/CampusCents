import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""

    var filteredTransactions: [Transaction] {
        let sorted = state.transactions.sorted(by: { $0.date > $1.date })
        if searchText.isEmpty {
            return sorted
        } else {
            return sorted.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.displayName.localizedCaseInsensitiveContains(searchText) ||
                String(transaction.amount).localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        List {
            if filteredTransactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(searchText.isEmpty ? "You have no past activity." : "No transactions match your search.")
                )
            } else {
                ForEach(filteredTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.vertical, 4)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search activity")
        .navigationTitle("Activity History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}
