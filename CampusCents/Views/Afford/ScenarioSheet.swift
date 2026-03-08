import SwiftUI

struct ScenarioSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState

    private enum ScenarioPreset: String, CaseIterable {
        case housing = "Housing Shift"
        case subscriptions = "Subscriptions"
    }

    @State private var preset: ScenarioPreset = .housing
    @State private var service = AIService()
    @State private var response: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Scenario", selection: $preset) {
                    ForEach(ScenarioPreset.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)

                if isLoading && response == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if let response {
                    Text(response.summary)
                        .font(.subheadline)
                    ForEach(response.points, id: \.self) { point in
                        Label(point, systemImage: "arrow.triangle.swap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(availability.statusLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Loading scenario insight…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Scenario Comparison")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task(id: preset) {
                await refresh()
            }
        }
    }

    @MainActor
    private func refresh() async {
        isLoading = true
        availability = await service.availability()
        response = await service.scenarioComparison(for: scenarioInput(from: state.budgetInput, preset: preset))
        isLoading = false
    }

    private func scenarioInput(from base: BudgetInput, preset: ScenarioPreset) -> ScenarioInput {
        switch preset {
        case .housing:
            var alternative = base
            alternative.housingType = base.housingType == .onCampus ? .offCampus : .onCampus
            if base.housingType == .onCampus {
                alternative.rent += 180
                alternative.mealPlan = max(0, base.mealPlan - 140)
                alternative.groceries += 90
                alternative.transportation += 40
            } else {
                alternative.rent = max(0, base.rent - 180)
                alternative.mealPlan += 140
                alternative.groceries = max(0, base.groceries - 90)
                alternative.transportation = max(0, base.transportation - 40)
            }
            return ScenarioInput(
                nameA: "Current \(base.housingType.displayName)",
                scenarioA: base,
                nameB: "Alternative \(alternative.housingType.displayName)",
                scenarioB: alternative
            )
        case .subscriptions:
            var alternative = base
            alternative.subscriptions = 0
            return ScenarioInput(
                nameA: "Keep Subscriptions",
                scenarioA: base,
                nameB: "Cancel Subscriptions",
                scenarioB: alternative
            )
        }
    }
}
