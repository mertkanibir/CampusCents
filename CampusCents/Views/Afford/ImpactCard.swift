import SwiftUI

struct ImpactCard: View {
    @EnvironmentObject var state: AppState
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Impact Insight")
                    .font(.headline)
                Spacer()
                Text(availability.isAvailable ? "On-device" : "Fallback")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(availability.isAvailable ? Colors.mint : Colors.sun)
            }

            if isLoading && response == nil {
                ProgressView()
            } else if let response {
                Text(response.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let impact = response.impact {
                    Text("Estimated impact: \(impact.displayName)")
                        .font(.caption.weight(.semibold))
                }
            } else {
                Text("Enter an item and price to get a budget impact reflection.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(availability.statusLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
}
