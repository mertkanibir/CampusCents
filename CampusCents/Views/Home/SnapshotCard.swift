import SwiftUI

struct SnapshotCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
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

    private var titleColors: [Color] {
        let baseColors = Array(rainbowColors.dropLast())
        let phaseOffset = Int((rainbowPhase / 360) * Double(baseColors.count)) % max(baseColors.count, 1)
        let rotated = Array(baseColors[phaseOffset...] + baseColors[..<phaseOffset])

        return [
            rotated[0],
            rotated[2 % rotated.count],
            rotated[4 % rotated.count],
            rotated[6 % rotated.count]
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("AI Overview", systemImage: "sparkles.rectangle.stack")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: titleColors,
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
                    .foregroundStyle(colorScheme == .dark ? .primary : Color.black.opacity(0.85))
                ForEach(Array(response.points.prefix(3).enumerated()), id: \.element) { index, point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(pointColors[index % pointColors.count])
                            .padding(.top, 5)
                        Text(point)
                            .font(.caption)
                            .foregroundStyle(colorScheme == .dark ? .primary.opacity(0.85) : Color.black.opacity(0.72))
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
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Colors.cardStroke(for: colorScheme), lineWidth: 1)
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
                        .opacity(colorScheme == .dark ? 0.9 : 0.85)
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
                                .opacity(colorScheme == .dark ? 0.42 : 0.28)
                        }
                }
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 14, y: 8)
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
