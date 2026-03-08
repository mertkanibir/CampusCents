import Foundation // the Apple Foundation Model

struct BudgetInput: Sendable, Equatable {
    enum BudgetStyle: String, Sendable, Codable, CaseIterable {
        case monthly
        case semester

        nonisolated var displayName: String {
            switch self {
            case .monthly: return "Monthly"
            case .semester: return "Semester"
            }
        }
    }

    enum HousingType: String, Sendable, Codable, CaseIterable {
        case onCampus
        case offCampus
        case commuter

        nonisolated var displayName: String {
            switch self {
            case .onCampus: return "On-Campus"
            case .offCampus: return "Off-Campus"
            case .commuter: return "Commuter"
            }
        }
    }

    var tuition: Double
    var aidScholarships: Double
    var rent: Double
    var mealPlan: Double
    var groceries: Double
    var transportation: Double
    var subscriptions: Double
    var personal: Double
    var savingsGoal: Double
    var monthlyIncome: Double
    var investments: Double
    var budgetStyle: BudgetStyle
    var housingType: HousingType
}

struct PurchaseInput: Sendable, Equatable {
    var name: String
    var amount: Double
    var snapshot: BudgetInput
}

struct ScenarioInput: Sendable, Equatable {
    var nameA: String
    var scenarioA: BudgetInput
    var nameB: String
    var scenarioB: BudgetInput
}

enum Flexibility: String, Sendable, Codable, CaseIterable {
    case tight
    case moderate
    case comfortable

    nonisolated var displayName: String {
        rawValue.capitalized
    }
}

enum Impact: String, Sendable, Codable, CaseIterable {
    case lowImpact
    case moderateImpact
    case highImpact

    nonisolated var displayName: String {
        switch self {
        case .lowImpact: return "Low Impact"
        case .moderateImpact: return "Moderate Impact"
        case .highImpact: return "High Impact"
        }
    }
}

struct AIResponse: Sendable, Codable, Equatable {
    var status: String
    var summary: String
    var points: [String]
    var flexibility: Flexibility
    var impact: Impact?
    var suggestions: [String]
}

enum AIStatus: Sendable, Equatable {
    case available
    case unsupportedDevice
    case intelligenceDisabled
    case modelNotReady
    case frameworkUnavailable
    case unknown(reason: String)

    nonisolated var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }

    nonisolated var statusLabel: String {
        switch self {
        case .available: return "On-device AI ready"
        case .unsupportedDevice: return "Apple Intelligence not supported on this device"
        case .intelligenceDisabled: return "Apple Intelligence is turned off"
        case .modelNotReady: return "On-device model is still getting ready"
        case .frameworkUnavailable: return "Foundation Models unavailable"
        case .unknown(let reason): return "AI unavailable: \(reason)"
        }
    }
}
