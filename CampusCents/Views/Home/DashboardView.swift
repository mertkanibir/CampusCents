import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    @State private var showingProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(alignment: .center) {
                        Text("Hi, \(state.profile.name)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            showingProfile = true
                        } label: {
                            AvatarView(profile: state.profile, size: 34)
                        }
                        .buttonStyle(.plain)
                    }

                    SummaryCard()
                    SnapshotCard()
                    RecentTransactionsCard(transactions: state.transactions.sorted(by: { $0.date > $1.date }))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingProfile) {
                NavigationStack {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showingProfile = false }
                            }
                        }
                }
            }
        }
    }
}
