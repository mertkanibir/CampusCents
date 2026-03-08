import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    TipsCarousel()
                    ForEach(state.insights) { item in
                        InsightRow(icon: item.icon, title: item.title, detail: item.detail, tint: item.tint)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
        }
    }
}
