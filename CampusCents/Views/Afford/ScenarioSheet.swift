import SwiftUI

struct ScenarioSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.82) : Color.primary.opacity(0.72)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.68) : Color.primary.opacity(0.56)
    }

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
                            .foregroundStyle(colorScheme == .dark ? primaryText : Colors.periwinkle)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.3 : 0.12), in: Capsule())

                        Text("Explore a smarter alternative")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(primaryText)
                        Text("See how one strategic change could reshape your budget pressure.")
                            .font(.subheadline)
                            .foregroundStyle(secondaryText)
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
                                    .foregroundStyle(secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let response {
                            Text(response.summary)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(secondaryText)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(response.points, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "arrow.triangle.swap")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Colors.blueMint)
                                            .padding(.top, 2)
                                        Text(point)
                                            .font(.caption)
                                            .foregroundStyle(secondaryText)
                                    }
                                }
                            }

                            Text(availability.statusLabel)
                                .font(.caption2)
                                .foregroundStyle(tertiaryText)
                        } else {
                            Text("Loading scenario insight...")
                                .font(.subheadline)
                                .foregroundStyle(secondaryText)
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
                alternative.adjustExpense(named: "Rent", by: 180)
                alternative.setExpense(named: "Meal Plan", to: max(0, alternative.getExpense(named: "Meal Plan") - 140))
                alternative.adjustExpense(named: "Groceries", by: 90)
                alternative.adjustExpense(named: "Transport", by: 40)
            } else {
                alternative.setExpense(named: "Rent", to: max(0, alternative.getExpense(named: "Rent") - 180))
                alternative.adjustExpense(named: "Meal Plan", by: 140)
                alternative.setExpense(named: "Groceries", to: max(0, alternative.getExpense(named: "Groceries") - 90))
                alternative.setExpense(named: "Transport", to: max(0, alternative.getExpense(named: "Transport") - 40))
            }
            return ScenarioInput(
                nameA: "Current \(base.housingType.displayName)",
                scenarioA: base,
                nameB: "Alternative \(alternative.housingType.displayName)",
                scenarioB: alternative
            )
        case .subscriptions:
            var alternative = base
            alternative.setExpense(named: "Subscriptions", to: 0)
            return ScenarioInput(
                nameA: "Keep Subscriptions",
                scenarioA: base,
                nameB: "Cancel Subscriptions",
                scenarioB: alternative
            )
        }
    }
}
