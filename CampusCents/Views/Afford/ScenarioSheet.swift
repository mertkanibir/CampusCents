import SwiftUI

struct ScenarioSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme

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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("AI Scenario Compare", systemImage: "sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Colors.periwinkle)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.2 : 0.12), in: Capsule())

                        Text("Explore a smarter alternative")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("See how one strategic change could reshape your budget pressure.")
                            .font(.subheadline)
                            .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.78 : 0.64))
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Scenario", selection: $preset) {
                            ForEach(ScenarioPreset.allCases, id: \.self) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)

                        if isLoading && response == nil {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Running AI comparison...")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.76 : 0.62))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let response {
                            Text(response.summary)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.82 : 0.72))

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(response.points, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "arrow.triangle.swap")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Colors.blueMint)
                                            .padding(.top, 2)
                                        Text(point)
                                            .font(.caption)
                                            .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.76 : 0.64))
                                    }
                                }
                            }

                            Text(availability.statusLabel)
                                .font(.caption2)
                                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.64 : 0.52))
                        } else {
                            Text("Loading scenario insight...")
                                .font(.subheadline)
                                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.72 : 0.6))
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
                    }
                }
                .padding()
            }
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
