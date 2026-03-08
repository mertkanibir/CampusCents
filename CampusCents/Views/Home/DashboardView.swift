import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SummaryCard()
                    SpentRemainingCard()
                    SnapshotCard()
                    RecentTransactionsCard(transactions: state.transactions.sorted(by: { $0.date > $1.date }))
                }
                .padding()
            }
            .navigationTitle("CampusCents")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AvatarView(profile: state.profile, size: 34)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionView()
                    .environmentObject(state)
            }
        }
    }
}
