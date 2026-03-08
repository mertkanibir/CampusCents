import SwiftUI

struct SnapshotCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var service = AIService()
    @State private var response: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false

    private var key: String {
        "\(state.profile.id.uuidString)-\(state.total)-\(state.spent)-\(state.transactions.count)"
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.17, green: 0.26, blue: 0.52),
                                Color(red: 0.06, green: 0.24, blue: 0.30),
                                Color(red: 0.04, green: 0.08, blue: 0.18)
                            ]
                            : [
                                Colors.periwinkle.opacity(0.22),
                                Colors.blueMint.opacity(0.12),
                                Color.white.opacity(0.95)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Colors.periwinkle.opacity(colorScheme == .dark ? 0.9 : 0.7),
                                    Colors.blueMint.opacity(colorScheme == .dark ? 0.7 : 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }

            Circle()
                .fill(Colors.blueMint.opacity(colorScheme == .dark ? 0.22 : 0.16))
                .frame(width: 140, height: 140)
                .blur(radius: 22)
                .offset(x: 160, y: -10)

            Circle()
                .fill(Colors.periwinkle.opacity(colorScheme == .dark ? 0.20 : 0.1))
                .frame(width: 180, height: 180)
                .blur(radius: 28)
                .offset(x: -30, y: 80)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("AI Insights", systemImage: "sparkles.rectangle.stack")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(primaryText)
                }

                if isLoading && response == nil {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Generating budget snapshot…")
                            .font(.subheadline)
                            .foregroundStyle(secondaryText)
                    }
                } else if let response {
                    Text(response.summary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(secondaryText)

                    ForEach(Array(response.points.prefix(3).enumerated()), id: \.offset) { _, point in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 7))
                                .foregroundStyle(Colors.periwinkle)
                                .padding(.top, 5)
                            Text(point)
                                .font(.caption)
                                .foregroundStyle(tertiaryText)
                        }
                    }
                } else {
                    Text("Generating budget snapshot…")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: Colors.periwinkle.opacity(colorScheme == .dark ? 0.2 : 0.14), radius: 20, y: 10)
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
