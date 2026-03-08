import SwiftUI

struct TipsCarousel: View {
    @EnvironmentObject var state: AppState
    @State private var service = AIService()
    @State private var insights: [String] = []

    private var key: String {
        "\(state.profile.id.uuidString)-\(state.spent)-\(state.total)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Insights")
                .font(.headline)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(insights, id: \.self) { insight in
                        Text(insight)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(width: 280, alignment: .leading)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal)
            }
        }
        .task(id: key) {
            insights = await service.spendingPressureInsights(for: state.budgetInput)
        }
    }
}
