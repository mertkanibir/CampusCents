import SwiftUI

struct BudgetCategory: Identifiable, Hashable, Codable {
    enum Kind: Hashable, Codable, Equatable {
        case income
        case savings
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
        case custom(id: String, name: String, desc: String, icon: String, tint: ColorValue, isIncome: Bool)

        init(from decoder: Decoder) throws {
            if let str = try? decoder.singleValueContainer().decode(String.self) {
                switch str {
                case "income": self = .income
                case "savings": self = .savings
                case "investment": self = .investment
                case "tuition": self = .tuition
                case "aid": self = .aid
                case "rent": self = .rent
                case "utilities": self = .utilities
                case "mealPlan": self = .mealPlan
                case "groceries": self = .groceries
                case "transportation": self = .transportation
                case "subscriptions": self = .subscriptions
                case "personal": self = .personal
                default:
                    self = .custom(id: str, name: str, desc: "", icon: "star.fill", tint: ColorValue(Colors.peach), isIncome: false)
                }
                return
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let customDict = try? container.nestedContainer(keyedBy: CustomKeys.self, forKey: .custom) {
                 let id = try customDict.decode(String.self, forKey: .id)
                 let name = try customDict.decode(String.self, forKey: .name)
                 let icon = try customDict.decode(String.self, forKey: .icon)
                 let tint = try customDict.decode(ColorValue.self, forKey: .tint)
                 let isIncome = try customDict.decode(Bool.self, forKey: .isIncome)
                 let desc = try customDict.decodeIfPresent(String.self, forKey: .desc) ?? ""
                 self = .custom(id: id, name: name, desc: desc, icon: icon, tint: tint, isIncome: isIncome)
                 return
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid Kind"))
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .custom(let id, let name, let desc, let icon, let tint, let isIncome):
                var container = encoder.container(keyedBy: CodingKeys.self)
                var customDict = container.nestedContainer(keyedBy: CustomKeys.self, forKey: .custom)
                try customDict.encode(id, forKey: .id)
                try customDict.encode(name, forKey: .name)
                try customDict.encode(desc, forKey: .desc)
                try customDict.encode(icon, forKey: .icon)
                try customDict.encode(tint, forKey: .tint)
                try customDict.encode(isIncome, forKey: .isIncome)
            default:
                var container = encoder.singleValueContainer()
                let strVal: String
                switch self {
                case .income: strVal = "income"
                case .savings: strVal = "savings"
                case .investment: strVal = "investment"
                case .tuition: strVal = "tuition"
                case .aid: strVal = "aid"
                case .rent: strVal = "rent"
                case .utilities: strVal = "utilities"
                case .mealPlan: strVal = "mealPlan"
                case .groceries: strVal = "groceries"
                case .transportation: strVal = "transportation"
                case .subscriptions: strVal = "subscriptions"
                case .personal: strVal = "personal"
                default: fatalError()
                }
                try container.encode(strVal)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case custom
        }
        private enum CustomKeys: String, CodingKey {
            case id, name, desc, icon, tint, isIncome
        }

        var displayName: String {
            switch self {
            case .income: return "Income"
            case .savings: return "Savings per month"
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
            case .custom(_, let name, _, _, _, _): return name
            }
        }

        var icon: String {
            switch self {
            case .income: return "dollarsign.circle.fill"
            case .savings: return "building.columns.fill"
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
            case .custom(_, _, _, let icon, _, _): return icon
            }
        }

        var tint: Color {
            switch self {
            case .income: return Colors.mint
            case .savings: return Colors.blueMint
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
            case .custom(_, _, _, _, let tint, _): return tint.color
            }
        }
        
        var isIncome: Bool {
            switch self {
            case .income, .savings: return true
            case .custom(_, _, _, _, _, let isInc): return isInc
            default: return false
            }
        }

        var kindKey: String {
            switch self {
            case .income: return "income"
            case .savings: return "savings"
            case .investment: return "investment"
            case .tuition: return "tuition"
            case .aid: return "aid"
            case .rent: return "rent"
            case .utilities: return "utilities"
            case .mealPlan: return "mealPlan"
            case .groceries: return "groceries"
            case .transportation: return "transportation"
            case .subscriptions: return "subscriptions"
            case .personal: return "personal"
            case .custom(let id, _, _, _, _, _): return id
            }
        }

        static func kind(forKey key: String) -> BudgetCategory.Kind? {
            switch key.lowercased() {
            case "income": return .income
            case "savings": return .savings
            case "investment": return .investment
            case "tuition": return .tuition
            case "aid": return .aid
            case "rent": return .rent
            case "utilities": return .utilities
            case "mealplan": return .mealPlan
            case "groceries": return .groceries
            case "transportation": return .transportation
            case "subscriptions": return .subscriptions
            case "personal": return .personal
            default: return nil
            }
        }

        var desc: String? {
            if case .custom(_, _, let description, _, _, _) = self { return description }
            return nil
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
        let kinds: [Kind] = [.income, .savings, .investment, .tuition, .aid, .rent, .utilities, .mealPlan, .groceries, .transportation, .subscriptions, .personal]
        var categories = kinds.map { kind in
            let budget: Double
            switch kind {
            case .income: budget = profile.monthlyIncome
            case .savings: budget = profile.savings
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
            default: budget = 0
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
        categories.append(contentsOf: profile.customCategories)
        return categories
    }

    static let sample: [BudgetCategory] = [
        .init(id: UUID(), kind: .income, name: "Monthly Income", budget: 700, spent: 700, color: .init(Colors.mint)),
        .init(id: UUID(), kind: .savings, name: "Savings per month", budget: 1500, spent: 1500, color: .init(Colors.blueMint)),
        .init(id: UUID(), kind: .investment, name: "Investments", budget: 200, spent: 0, color: .init(Colors.periwinkle)),
        
        .init(id: UUID(), kind: .tuition, name: "Tuition", budget: 6200, spent: 6200, color: .init(Colors.rose)),
        .init(id: UUID(), kind: .rent, name: "Rent", budget: 750, spent: 750, color: .init(Colors.sky)),
        .init(id: UUID(), kind: .groceries, name: "Groceries", budget: 220, spent: 190, color: .init(Colors.blueMint)),
        .init(id: UUID(), kind: .subscriptions, name: "Subscriptions", budget: 35, spent: 28, color: .init(Colors.pistachio)),
        .init(id: UUID(), kind: .personal, name: "Personal", budget: 180, spent: 140, color: .init(Colors.peach))
    ]
}

