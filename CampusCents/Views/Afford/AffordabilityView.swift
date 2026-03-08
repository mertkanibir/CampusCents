import SwiftUI

struct AffordabilityView: View {
    @EnvironmentObject var state: AppState
    @State private var itemName = "Coffee with friends"
    @State private var priceText = "12"
    @State private var showScenarioSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                GroupBox("Can I afford this?") {
                    VStack(spacing: 10) {
                        LabeledField("Item", value: $itemName)
                        LabeledField("Price", value: $priceText)
                    }
                    .padding(.top, 4)
                }

                ResultCard(result: evaluation)
                ImpactCard(itemName: itemName, priceText: priceText)

                GroupBox("Quick context") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remaining monthly budget: \(state.remaining.currency)")
                        Text("Personal + groceries budget: \((state.profile.personal + state.profile.groceries).currency)")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Affordability")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var evaluation: AffordabilityResult {
        let price = Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let discretionary = state.profile.personal + state.profile.groceries
        let ratio = price / max(1, discretionary)

        switch ratio {
        case ..<0.1:
            return .safe("This purchase has very low impact on your monthly plan.")
        case ..<0.25:
            return .mostlySafe("Reasonable choice. Keep an eye on repeated buys.")
        case ..<0.5:
            return .risky("This is meaningful for your current discretionary budget.")
        default:
            return .no("This has high budget impact unless another category is adjusted.")
        }
    }
}
