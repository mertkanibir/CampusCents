import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    @State private var showingProfile = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ActivityGradientView(colors: state.activityGradientColors)
                    .frame(height: 152)
                    .frame(maxWidth: .infinity)

                ScrollView {
                    VStack(spacing: 16) {
                        HStack(alignment: .center) {
                            Text("Hi, \(state.profile.name)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                showingProfile = true
                            } label: {
                                AvatarView(profile: state.profile, size: 34)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 8)

                        SummaryCard()
                        SnapshotCard()
                        RecentTransactionsCard(transactions: state.transactions.sorted(by: { $0.date > $1.date }))
                    }
                    .padding()
                    .padding(.bottom, 24)
                }
                .overlay(alignment: .top) { TopSafeAreaGradientOverlay() }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingProfile) {
                NavigationStack {
                    ProfileView()
                        .environmentObject(state)
                }
            }
        }
    }
}
