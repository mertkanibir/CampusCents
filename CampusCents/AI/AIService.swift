import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

actor AIService {
    private let fallbackEngine = FallbackEngine()

    func availability() -> AIStatus {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            switch model.availability {
            case .available:
                return .available
            case .unavailable(.deviceNotEligible):
                return .unsupportedDevice
            case .unavailable(.appleIntelligenceNotEnabled):
                return .intelligenceDisabled
            case .unavailable(.modelNotReady):
                return .modelNotReady
            case .unavailable(let reason):
                return .unknown(reason: String(describing: reason))
            }
        }
        return .frameworkUnavailable
        #else
        return .frameworkUnavailable
        #endif
    }

    func financialSnapshot(for input: BudgetInput) async -> AIResponse {
        guard availability().isAvailable else {
            return fallbackEngine.snapshotInsight(for: input)
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    model: .default,
                    instructions: Prompts.systemBehavior
                )
                let response = try await session.respond(
                    to: Prompts.snapshotPrompt(for: input),
                    generating: AIGuidedInsightPayload.self
                )
                return response.content.toResponse(defaultStatus: "on-device-ai")
            } catch {
                return fallbackEngine.snapshotInsight(for: input)
            }
        }
        #endif

        return fallbackEngine.snapshotInsight(for: input)
    }

    func affordabilityReflection(for input: PurchaseInput) async -> AIResponse {
        guard availability().isAvailable else {
            return fallbackEngine.affordabilityInsight(for: input)
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    model: .default,
                    instructions: Prompts.systemBehavior
                )
                let response = try await session.respond(
                    to: Prompts.affordabilityPrompt(for: input),
                    generating: AIGuidedInsightPayload.self
                )
                var mapped = response.content.toResponse(defaultStatus: "on-device-ai")
                if mapped.impact == nil {
                    mapped.impact = fallbackEngine.affordabilityInsight(for: input).impact
                }
                return mapped
            } catch {
                return fallbackEngine.affordabilityInsight(for: input)
            }
        }
        #endif

        return fallbackEngine.affordabilityInsight(for: input)
    }

    func scenarioComparison(for input: ScenarioInput) async -> AIResponse {
        guard availability().isAvailable else {
            return fallbackEngine.scenarioInsight(for: input)
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    model: .default,
                    instructions: Prompts.systemBehavior
                )
                let response = try await session.respond(
                    to: Prompts.scenarioPrompt(for: input),
                    generating: AIGuidedInsightPayload.self
                )
                return response.content.toResponse(defaultStatus: "on-device-ai")
            } catch {
                return fallbackEngine.scenarioInsight(for: input)
            }
        }
        #endif

        return fallbackEngine.scenarioInsight(for: input)
    }

    /// Parses natural-language transaction text. Uses a reliable rule-based parser first; if Apple Foundation Models are available, tries AI and only uses it when the result is valid (so bad AI output never wins).
    func parseTransaction(from userText: String, categoryKeys: [String]) async -> ParsedTransactionInput? {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Always run fallback first — it's reliable and works without AI.
        let fallbackResult = fallbackEngine.parseTransactionFallback(trimmed)

        guard availability().isAvailable else {
            return fallbackResult
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    model: .default,
                    instructions: Prompts.transactionParseInstruction
                )
                let response = try await session.respond(
                    to: Prompts.transactionParsePrompt(userText: trimmed, categoryKeys: categoryKeys),
                    generating: AIParsedTransactionPayload.self
                )
                let parsed = response.content
                let title = parsed.transactionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let amount = max(0, parsed.amount)
                // Only use AI result if it looks valid; otherwise keep fallback.
                guard !title.isEmpty, amount > 0 else {
                    return fallbackResult
                }
                let key = categoryKeys.contains(parsed.categoryKey) ? parsed.categoryKey : (fallbackResult?.categoryKey ?? "personal")
                let dateDesc = parsed.dateDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                return ParsedTransactionInput(
                    transactionTitle: title,
                    amount: amount,
                    categoryKey: key,
                    dateDescription: dateDesc.isEmpty ? "today" : dateDesc
                )
            } catch {
                return fallbackResult
            }
        }
        #endif

        return fallbackResult
    }

    func spendingPressureInsights(for input: BudgetInput) async -> [String] {
        let primary = await financialSnapshot(for: input)
        if primary.points.isEmpty {
            return fallbackEngine.spendingPressureInsights(for: input)
        }
        return primary.points
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
private struct AIParsedTransactionPayload {
    var transactionTitle: String
    var amount: Double
    var categoryKey: String
    var dateDescription: String
}

@available(iOS 26.0, *)
@Generable
private struct AIGuidedInsightPayload {
    var overallStatus: String
    var summary: String
    var pressurePoints: [String]
    var flexibilityLevel: String
    var affordabilityImpact: String?
    var suggestionsForAwareness: [String]

    func toResponse(defaultStatus: String) -> AIResponse {
        AIResponse(
            status: overallStatus.isEmpty ? defaultStatus : overallStatus,
            summary: summary,
            points: pressurePoints,
            flexibility: Flexibility(rawValue: flexibilityLevel.lowercased()) ?? .moderate,
            impact: {
                guard let affordabilityImpact else { return nil }
                return Impact(rawValue: affordabilityImpact.replacingOccurrences(of: " ", with: "").lowercased())
            }(),
            suggestions: suggestionsForAwareness
        )
    }
}
#endif
