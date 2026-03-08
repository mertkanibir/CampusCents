import SwiftUI

struct BudgetCategory: Identifiable, Hashable, Codable {
    enum Kind: String, CaseIterable, Codable {
        case income
        case investment
        case tuition
        case aid
        case rent
        case utilities
        case mealPlan
        case groceries
        case transportation
        case subscriptions
        case personal

        var displayName: String {
            switch self {
            case .income: return "Income"
            case .investment: return "Investments"
            case .tuition: return "Tuition"
            case .aid: return "Scholarships & Aid"
            case .rent: return "Rent"
            case .utilities: return "Utilities"
            case .mealPlan: return "Meal Plan"
            case .groceries: return "Groceries"
            case .transportation: return "Transport"
            case .subscriptions: return "Subscriptions"
            case .personal: return "Personal"
            }
        }

        var icon: String {
            switch self {
            case .income: return "dollarsign.circle.fill"
            case .investment: return "chart.pie.fill"
            case .tuition: return "graduationcap.fill"
            case .aid: return "gift.fill"
            case .rent: return "house.fill"
            case .utilities: return "bolt.fill"
            case .mealPlan: return "fork.knife"
            case .groceries: return "cart.fill"
            case .transportation: return "car.fill"
            case .subscriptions: return "play.circle.fill"
            case .personal: return "face.smiling.fill"
            }
        }

        var tint: Color {
            switch self {
            case .income: return Colors.mint
            case .investment: return Colors.periwinkle
            case .tuition: return Colors.rose
            case .aid: return Colors.mint
            case .rent: return Colors.sky
            case .utilities: return Colors.lavender
            case .mealPlan: return Colors.sun
            case .groceries: return Colors.blueMint
            case .transportation: return Colors.periwinkle
            case .subscriptions: return Colors.pistachio
            case .personal: return Colors.peach
            }
        }
    }

    let id: UUID
    var kind: Kind
    var name: String
    var budget: Double
    var spent: Double
    var color: ColorValue

    var remaining: Double {
        max(0, budget - spent)
    }

    static func from(profile: StudentProfile) -> [BudgetCategory] {
        let kinds: [Kind] = [.tuition, .aid, .rent, .utilities, .mealPlan, .groceries, .transportation, .subscriptions, .personal]
        return kinds.map { kind in
            let budget: Double
            switch kind {
            case .income: budget = profile.monthlyIncome
            case .investment: budget = profile.investments
            case .tuition: budget = profile.tuition
            case .aid: budget = profile.scholarshipsAid
            case .rent: budget = profile.rent
            case .utilities: budget = profile.utilities
            case .mealPlan: budget = profile.mealPlan
            case .groceries: budget = profile.groceries
            case .transportation: budget = profile.transportation
            case .subscriptions: budget = profile.subscriptions
            case .personal: budget = profile.personal
            }
            return BudgetCategory(
                id: UUID(),
                kind: kind,
                name: kind.displayName,
                budget: budget,
                spent: 0,
                color: .init(kind.tint)
            )
        }
    }

    static let sample: [BudgetCategory] = [
        .init(id: UUID(), kind: .income, name: "Monthly Income", budget: 700, spent: 700, color: .init(Colors.mint)),
        .init(id: UUID(), kind: .investment, name: "Investments", budget: 200, spent: 0, color: .init(Colors.periwinkle)),
        
        .init(id: UUID(), kind: .tuition, name: "Tuition", budget: 6200, spent: 6200, color: .init(Colors.rose)),
        .init(id: UUID(), kind: .aid, name: "Scholarships & Aid", budget: 3500, spent: 0, color: .init(Colors.mint)),
        .init(id: UUID(), kind: .rent, name: "Rent", budget: 750, spent: 750, color: .init(Colors.sky)),
        .init(id: UUID(), kind: .utilities, name: "Utilities", budget: 120, spent: 110, color: .init(Colors.lavender)),
        .init(id: UUID(), kind: .mealPlan, name: "Meal Plan", budget: 280, spent: 210, color: .init(Colors.sun)),
        .init(id: UUID(), kind: .groceries, name: "Groceries", budget: 220, spent: 190, color: .init(Colors.blueMint)),
        .init(id: UUID(), kind: .transportation, name: "Transport", budget: 90, spent: 60, color: .init(Colors.periwinkle)),
        .init(id: UUID(), kind: .subscriptions, name: "Subscriptions", budget: 35, spent: 28, color: .init(Colors.pistachio)),
        .init(id: UUID(), kind: .personal, name: "Personal", budget: 180, spent: 140, color: .init(Colors.peach))
    ]
}
