import Foundation

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

        nonisolated var description: String {
            switch self {
            case .monthly: return "Track spending week by week"
            case .semester: return "Plan by term (tuition 2–3x/year)"
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

        nonisolated var description: String {
            switch self {
            case .onCampus: return "Dorm or university housing"
            case .offCampus: return "Apartment or house"
            case .commuter: return "Living at home"
            }
        }
    }

    struct CategoryInput: Sendable, Equatable {
        var name: String
        var budget: Double
        var spent: Double
    }

    var savingsGoal: Double
    var budgetStyle: BudgetStyle
    var housingType: HousingType
    var incomes: [CategoryInput]
    var expenses: [CategoryInput]
    
    mutating func adjustExpense(named name: String, by amount: Double) {
        if let idx = expenses.firstIndex(where: { $0.name == name }) {
            expenses[idx].budget = max(0, expenses[idx].budget + amount)
        }
    }
    
    mutating func setExpense(named name: String, to amount: Double) {
        if let idx = expenses.firstIndex(where: { $0.name == name }) {
            expenses[idx].budget = max(0, amount)
        }
    }
    
    nonisolated func getExpense(named name: String) -> Double {
        expenses.first(where: { $0.name == name })?.budget ?? 0
    }
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

struct ParsedTransactionInput: Sendable, Equatable {
    var transactionTitle: String
    var amount: Double
    var categoryKey: String
    var dateDescription: String

    func resolvedDate(calendar: Calendar = .current, reference: Date = Date()) -> Date {
        let normalized = dateDescription.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.isEmpty || normalized == "today" {
            return calendar.startOfDay(for: reference)
        }
        if normalized == "yesterday" {
            return calendar.date(byAdding: .day, value: -1, to: reference).map { calendar.startOfDay(for: $0) } ?? reference
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        if let parsed = formatter.date(from: normalized) {
            return calendar.startOfDay(for: parsed)
        }
        return calendar.startOfDay(for: reference)
    }

    func dateLabel(calendar: Calendar = .current, reference: Date = Date()) -> String {
        let d = resolvedDate(calendar: calendar, reference: reference)
        if calendar.isDateInToday(d) { return "Today" }
        if calendar.isDateInYesterday(d) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: d)
    }
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
