import SwiftUI

struct BreakdownView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddCategory = false
    @State private var budgetStyle: BudgetInput.BudgetStyle = .monthly
    @State private var housingType: BudgetInput.HousingType = .offCampus

    private let primaryCardCornerRadius: CGFloat = 26
    private let secondaryCardCornerRadius: CGFloat = 24

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58)
    }

    private var quietText: Color {
        colorScheme == .dark ? Color.white.opacity(0.64) : Color.primary.opacity(0.52)
    }

    var incomeCategories: [BudgetCategory] {
        state.categories.filter { $0.kind.isIncome }
    }

    var expenseCategories: [BudgetCategory] {
        state.categories.filter { !$0.kind.isIncome }
    }

    private var totalBudget: Double {
        state.categories.reduce(0) { $0 + $1.budget }
    }

    private var totalSpent: Double {
        state.categories.filter { !$0.kind.isIncome }.reduce(0) { $0 + $1.spent }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard
                    planningCard
                    incomeCard
                    expendituresCard
                    addCategoryCard
                }
                .padding()
            }
            .overlay(alignment: .top) { ScrollEdgeOverlay() }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
                    .environmentObject(state)
            }
            .onAppear {
                budgetStyle = state.profile.budgetStyle
                housingType = state.profile.housingType
            }
            .onChange(of: budgetStyle) { _, new in
                var p = state.profile
                p.budgetStyle = new
                state.profile = p
            }
            .onChange(of: housingType) { _, new in
                var p = state.profile
                p.housingType = new
                state.profile = p
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.17, green: 0.26, blue: 0.52),
                                Color(red: 0.06, green: 0.24, blue: 0.30),
                                Color(red: 0.04, green: 0.08, blue: 0.18)
                            ]
                            : [
                                Colors.periwinkle.opacity(0.22),
                                Colors.blueMint.opacity(0.12),
                                Color.white.opacity(0.95)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Colors.periwinkle.opacity(colorScheme == .dark ? 0.9 : 0.7), Colors.blueMint.opacity(colorScheme == .dark ? 0.7 : 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }

            Circle()
                .fill(Colors.blueMint.opacity(colorScheme == .dark ? 0.22 : 0.16))
                .frame(width: 160, height: 160)
                .blur(radius: 22)
                .offset(x: 180, y: -20)

            Circle()
                .fill(Colors.periwinkle.opacity(colorScheme == .dark ? 0.20 : 0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: -40, y: 100)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plan and track by category.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Set budgets for income and expenses, then see how much you have left in each bucket as you spend.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    heroMetricTile(title: "Total budget", value: totalBudget.currency, tint: Colors.periwinkle)
                    heroMetricTile(title: "Spent this period", value: totalSpent.currency, tint: Colors.blueMint)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: Colors.periwinkle.opacity(colorScheme == .dark ? 0.2 : 0.14), radius: 20, y: 10)
    }

    private func heroMetricTile(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.76) : Color.primary.opacity(0.6))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(colorScheme == .dark ? 0.28 : 0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .dark ? 0.58 : 0.3), lineWidth: 1)
        }
    }

    private var planningCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Planning & style")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(primaryText)
                Text("How you plan your budget and where you live.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Budget style", systemImage: "calendar")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tertiaryText)
                    Picker("Budget Style", selection: $budgetStyle) {
                        ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Colors.periwinkle)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Housing type", systemImage: "house.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tertiaryText)
                    Picker("Housing Type", selection: $housingType) {
                        ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Colors.blueMint)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.08), radius: 18, y: 10)
    }

    private var incomeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Income")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(primaryText)
                Text("Money coming in this period.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }

            if incomeCategories.isEmpty {
                emptySectionPlaceholder(message: "No income categories. Add a custom category below.")
            } else {
                VStack(spacing: 10) {
                    ForEach(incomeCategories) { category in
                        CategoryRow(category: category)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 16, y: 8)
    }

    private var expendituresCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Expenditures")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(primaryText)
                Text("Where your money goes.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }

            if expenseCategories.isEmpty {
                emptySectionPlaceholder(message: "No expense categories yet. Add a custom category below.")
            } else {
                VStack(spacing: 10) {
                    ForEach(expenseCategories) { category in
                        CategoryRow(category: category)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 16, y: 8)
    }

    private var addCategoryCard: some View {
        Button {
            showingAddCategory = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Colors.periwinkle.opacity(colorScheme == .dark ? 0.35 : 0.2))
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Colors.periwinkle.opacity(colorScheme == .dark ? 0.6 : 0.4), lineWidth: 1)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Colors.periwinkle)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Add custom category")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(primaryText)
                    Text("Name, budget amount, icon & color")
                        .font(.caption)
                        .foregroundStyle(secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tertiaryText)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous)
                    .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func emptySectionPlaceholder(message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(secondaryText)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
