import SwiftUI

struct ImpactCard: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let itemName: String
    let priceText: String

    @State private var service = AIService()
    @State private var response: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false

    private var parsedPrice: Double {
        Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var key: String {
        "\(itemName)-\(parsedPrice)-\(state.profile.id.uuidString)-\(state.spent)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Impact Insight", systemImage: "brain.head.profile")
                        .font(.headline.weight(.semibold))
                    Text("AI reflection on this purchase in your current setup")
                        .font(.caption)
                        .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.68 : 0.56))
                }
                Spacer()
                availabilityBadge
            }

            if isLoading && response == nil {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Generating AI reflection...")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.76 : 0.62))
                }
            } else if let response {
                Text(response.summary)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.82 : 0.72))

                HStack(spacing: 10) {
                    if let impact = response.impact {
                        impactPill(text: impact.displayName, tint: impactTint(for: impact))
                    }
                    impactPill(
                        text: availability.isAvailable ? "Live on-device model" : "Fallback engine",
                        tint: availability.isAvailable ? Colors.mint : Colors.sun
                    )
                }

                Text("This section translates the score into plain-language guidance based on your saved budget data.")
                    .font(.caption)
                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.66 : 0.54))

                if !response.suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggested next move")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.66 : 0.54))
                        ForEach(Array(response.suggestions.prefix(2).enumerated()), id: \.offset) { _, suggestion in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "sparkle")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Colors.periwinkle)
                                    .padding(.top, 2)
                                Text(suggestion)
                                    .font(.caption)
                                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.76 : 0.64))
                            }
                        }
                    }
                }
            } else {
                Text("Enter an item and price to get a plain-language explanation of how this purchase could affect your budget.")
                    .font(.subheadline)
                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.72 : 0.6))
            }

            Text(availability.statusLabel)
                .font(.caption2)
                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.64 : 0.52))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: Colors.periwinkle.opacity(colorScheme == .dark ? 0.12 : 0.08), radius: 16, y: 8)
        .task(id: key) {
            await refresh()
        }
    }

    @MainActor
    private func refresh() async {
        guard parsedPrice > 0 else {
            response = nil
            return
        }
        isLoading = true
        availability = await service.availability()
        response = await service.affordabilityReflection(for: PurchaseInput(
            name: itemName,
            amount: parsedPrice,
            snapshot: state.budgetInput
        ))
        isLoading = false
    }

    private var availabilityBadge: some View {
        Text(availability.isAvailable ? "On-device AI" : "Fallback AI")
            .font(.caption.weight(.semibold))
            .foregroundStyle(availability.isAvailable ? Colors.mint : Colors.sun)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background((availability.isAvailable ? Colors.mint : Colors.sun).opacity(colorScheme == .dark ? 0.18 : 0.12), in: Capsule())
    }

    private func impactTint(for impact: Impact) -> Color {
        switch impact {
        case .lowImpact: Colors.mint
        case .moderateImpact: Colors.sun
        case .highImpact: Colors.rose
        }
    }

    private func impactPill(text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(colorScheme == .dark ? 0.18 : 0.10), in: Capsule())
    }
}
