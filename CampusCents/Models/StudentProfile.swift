import SwiftUI

struct StudentProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var school: String
    var term: String
    var monthlyIncome: Double
    var investments: Double
    var scholarshipsAid: Double
    var tuition: Double
    var rent: Double
    var utilities: Double
    var mealPlan: Double
    var groceries: Double
    var transportation: Double
    var subscriptions: Double
    var personal: Double
    var savingsGoal: Double
    var budgetStyle: BudgetInput.BudgetStyle
    var housingType: BudgetInput.HousingType
    var avatarData: Data?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case school
        case term
        case monthlyIncome
        case investments
        case scholarshipsAid
        case tuition
        case rent
        case utilities
        case mealPlan
        case groceries
        case transportation
        case subscriptions
        case personal
        case savingsGoal
        case budgetStyle
        case housingType
        case avatarData
    }

    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased().isEmpty ? "CC" : letters.joined().uppercased()
    }

    static let emptyForOnboarding = StudentProfile(
        id: UUID(),
        name: "",
        school: "",
        term: "Spring \(Calendar.current.component(.year, from: Date()))",
        monthlyIncome: 0,
        investments: 0,
        scholarshipsAid: 0,
        tuition: 0,
        rent: 0,
        utilities: 0,
        mealPlan: 0,
        groceries: 0,
        transportation: 0,
        subscriptions: 0,
        personal: 0,
        savingsGoal: 0,
        budgetStyle: .monthly,
        housingType: .offCampus,
        avatarData: nil
    )

    static let sample = StudentProfile(
        id: UUID(),
        name: "Mike Lewis",
        school: "Binghamton University",
        term: "Spring 2028",
        monthlyIncome: 700,
        investments: 200,
        scholarshipsAid: 5000,
        tuition: 6800,
        rent: 900,
        utilities: 120,
        mealPlan: 1340,
        groceries: 400,
        transportation: 90,
        subscriptions: 39,
        personal: 180,
        savingsGoal: 120,
        budgetStyle: .monthly,
        housingType: .offCampus,
        avatarData: nil
    )

    init(
        id: UUID,
        name: String,
        school: String,
        term: String,
        monthlyIncome: Double,
        investments: Double,
        scholarshipsAid: Double,
        tuition: Double,
        rent: Double,
        utilities: Double,
        mealPlan: Double,
        groceries: Double,
        transportation: Double,
        subscriptions: Double,
        personal: Double,
        savingsGoal: Double,
        budgetStyle: BudgetInput.BudgetStyle,
        housingType: BudgetInput.HousingType,
        avatarData: Data?
    ) {
        self.id = id
        self.name = name
        self.school = school
        self.term = term
        self.monthlyIncome = monthlyIncome
        self.investments = investments
        self.scholarshipsAid = scholarshipsAid
        self.tuition = tuition
        self.rent = rent
        self.utilities = utilities
        self.mealPlan = mealPlan
        self.groceries = groceries
        self.transportation = transportation
        self.subscriptions = subscriptions
        self.personal = personal
        self.savingsGoal = savingsGoal
        self.budgetStyle = budgetStyle
        self.housingType = housingType
        self.avatarData = avatarData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        school = try container.decode(String.self, forKey: .school)
        term = try container.decode(String.self, forKey: .term)
        monthlyIncome = try container.decode(Double.self, forKey: .monthlyIncome)
        investments = try container.decodeIfPresent(Double.self, forKey: .investments) ?? 0
        scholarshipsAid = try container.decodeIfPresent(Double.self, forKey: .scholarshipsAid) ?? 0
        tuition = try container.decodeIfPresent(Double.self, forKey: .tuition) ?? 0
        rent = try container.decode(Double.self, forKey: .rent)
        utilities = try container.decode(Double.self, forKey: .utilities)
        mealPlan = try container.decode(Double.self, forKey: .mealPlan)
        groceries = try container.decode(Double.self, forKey: .groceries)
        transportation = try container.decode(Double.self, forKey: .transportation)
        subscriptions = try container.decode(Double.self, forKey: .subscriptions)
        personal = try container.decode(Double.self, forKey: .personal)
        savingsGoal = try container.decodeIfPresent(Double.self, forKey: .savingsGoal) ?? 100
        budgetStyle = try container.decodeIfPresent(BudgetInput.BudgetStyle.self, forKey: .budgetStyle) ?? .monthly
        housingType = try container.decodeIfPresent(BudgetInput.HousingType.self, forKey: .housingType) ?? .offCampus
        avatarData = try container.decodeIfPresent(Data.self, forKey: .avatarData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(school, forKey: .school)
        try container.encode(term, forKey: .term)
        try container.encode(monthlyIncome, forKey: .monthlyIncome)
        try container.encode(investments, forKey: .investments)
        try container.encode(scholarshipsAid, forKey: .scholarshipsAid)
        try container.encode(tuition, forKey: .tuition)
        try container.encode(rent, forKey: .rent)
        try container.encode(utilities, forKey: .utilities)
        try container.encode(mealPlan, forKey: .mealPlan)
        try container.encode(groceries, forKey: .groceries)
        try container.encode(transportation, forKey: .transportation)
        try container.encode(subscriptions, forKey: .subscriptions)
        try container.encode(personal, forKey: .personal)
        try container.encode(savingsGoal, forKey: .savingsGoal)
        try container.encode(budgetStyle, forKey: .budgetStyle)
        try container.encode(housingType, forKey: .housingType)
        try container.encodeIfPresent(avatarData, forKey: .avatarData)
    }
}
