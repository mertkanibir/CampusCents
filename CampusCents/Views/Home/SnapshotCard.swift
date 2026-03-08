import SwiftUI

struct SnapshotCard: View {
    @EnvironmentObject var state: AppState
    @State private var service = AIService()
    @State private var response: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false
    @State private var rainbowPhase = 0.0

    private var key: String {
        "\(state.profile.id.uuidString)-\(state.total)-\(state.spent)-\(state.transactions.count)"
    }

    private var rainbowColors: [Color] {
        [Colors.sky, Colors.blueMint, Colors.mint, Colors.sun, Colors.peach, Colors.rose, Colors.lavender, Colors.periwinkle, Colors.sky]
    }

    private var pointColors: [Color] {
        [Colors.periwinkle, Colors.mint, Colors.peach]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("AI Snapshot", systemImage: "sparkles.rectangle.stack")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Colors.periwinkle, Colors.rose],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            if isLoading && response == nil {
                ProgressView()
            } else if let response {
                Text(response.summary)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                ForEach(Array(response.points.prefix(3).enumerated()), id: \.element) { index, point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(pointColors[index % pointColors.count])
                            .padding(.top, 5)
                        Text(point)
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.85))
                    }
                }
            } else {
                Text("Generating budget snapshot…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        colors: rainbowColors,
                        center: .center,
                        angle: .degrees(rainbowPhase)
                    ),
                    lineWidth: 1.6
                )
                .opacity(0.9)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            AngularGradient(
                                colors: rainbowColors,
                                center: .center,
                                angle: .degrees(rainbowPhase)
                            ),
                            lineWidth: 7
                        )
                        .blur(radius: 9)
                        .opacity(0.42)
                }
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rainbowPhase = 360
            }
        }
        .task(id: key) {
            await refresh()
        }
    }

    @MainActor
    private func refresh() async {
        isLoading = true
        availability = await service.availability()
        response = await service.financialSnapshot(for: state.budgetInput)
        isLoading = false
    }
}
