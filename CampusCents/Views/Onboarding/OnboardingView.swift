import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var page = 0
    @State private var draftProfile: StudentProfile = .emptyForOnboarding
    @State private var isGoingForward = true

    private var totalPages: Int { 8 }
    private var isSetupPhase: Bool { page >= 2 }
    private var setupStep: SetupStep {
        guard page >= 2, let step = SetupStep(rawValue: page - 2) else { return .profile }
        return step
    }

    private static var binghamtonGreen: Color {
        Color(red: 0, green: 90/255, blue: 67/255)
    }

    private var welcomePageBackground: LinearGradient {
        let base = Self.binghamtonGreen
        let endColor: Color
        if colorScheme == .dark {
            endColor = base.opacity(0.94)
        } else {
            endColor = base.opacity(0.97)
        }
        return LinearGradient(
            colors: [base, endColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var appBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.14, blue: 0.12),
                    Color(red: 0.08, green: 0.12, blue: 0.11),
                    Color(red: 0.10, green: 0.14, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color(red: 0.88, green: 0.97, blue: 0.93),
                Color(red: 0.90, green: 0.96, blue: 0.94),
                Color(red: 0.92, green: 0.95, blue: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var primaryLabel: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryLabel: Color {
        colorScheme == .dark ? .white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch page {
                case 0:
                    welcomePage
                case 1:
                    combinedFeaturesPage
                default:
                    setupContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(page)
            .transition(.asymmetric(
                insertion: .move(edge: isGoingForward ? .trailing : .leading),
                removal: .move(edge: isGoingForward ? .leading : .trailing)
            ))

            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i <= page ? accentColor : accentColor.opacity(0.3))
                        .frame(width: i == page ? 12 : 6, height: 6)
                        .animation(.smooth(duration: 0.2), value: page)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 12)

            HStack(spacing: 12) {
                if page > 0 {
                    Button {
                        isGoingForward = false
                        withAnimation(.smooth(duration: 0.35)) {
                            page = max(0, page - 1)
                        }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(OnboardingButtonStyle(accent: Colors.mint, isFilled: false))
                    .frame(width: 100)
                }

                Button(action: advancePage) {
                    Text(buttonTitle)
                        .font(.headline.weight(.semibold))
                }
                .buttonStyle(OnboardingButtonStyle(accent: Colors.mint))
                .disabled(isSetupPhase && !isWizardStepComplete(profile: draftProfile, step: setupStep))
                .opacity(isSetupPhase && !isWizardStepComplete(profile: draftProfile, step: setupStep) ? 0.6 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Group {
                if page == 0 {
                    welcomePageBackground
                } else {
                    appBackground
                }
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.5), value: page)
    }

    private var accentColor: Color {
        if isSetupPhase { return Colors.mint }
        switch page {
        case 0: return Colors.pistachio
        case 1: return Colors.mint
        default: return Colors.mint
        }
    }

    private var buttonTitle: String {
        if page == totalPages - 1 {
            return "Get Started"
        }
        return "Continue"
    }

    private func advancePage() {
        isGoingForward = true
        withAnimation(.smooth(duration: 0.35)) {
            if page == totalPages - 1 {
                state.completeOnboarding(with: draftProfile)
            } else {
                page += 1
            }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)
            Image("CampusCentsIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 16, y: 6)

            VStack(spacing: 10) {
                Text("Welcome to")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                Text("CampusCents")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Your intelligent budgeting companion for student life.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }

    private var combinedFeaturesPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Everything you need to stay on budget")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(primaryLabel)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                Text("CampusCents helps you track spending, get AI insights, and see what you can afford before you buy. Next we'll set up your profile and budget.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryLabel)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 12)

                featureCard(
                    icon: "chart.pie.fill",
                    title: "Track your money",
                    subtitle: "See exactly where your cash goes with clear budgets and daily insights.",
                    accent: Colors.mint,
                    content: trackMockContent
                )
                featureCard(
                    icon: "sparkles.rectangle.stack",
                    title: "AI Budget Insights",
                    subtitle: "Get personalized insights and tips powered by on-device AI.",
                    accent: Colors.periwinkle,
                    content: snapshotMockContent
                )
                featureCard(
                    icon: "questionmark.circle.fill",
                    title: "Can I afford it?",
                    subtitle: "Before you buy, see how it affects your budget in real time.",
                    accent: Colors.rose,
                    content: affordMockContent
                )
                featureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Stay on track",
                    subtitle: "Set goals, monitor progress, and get gentle nudges when you're over budget.",
                    accent: Colors.blueMint,
                    content: stayOnTrackMockContent
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }

    private func featureCard<Content: View>(icon: String, title: String, subtitle: String, accent: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(primaryLabel)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(secondaryLabel)
                }
                Spacer(minLength: 0)
            }
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1))
    }

    private func trackMockContent() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                mockMetricCell(label: "12 days left", value: "~$45/day", tint: Colors.mint)
                mockMetricCell(label: "Remaining", value: "$540", tint: Colors.mint)
            }
            HStack(alignment: .top, spacing: 10) {
                mockMetricCell(label: "Income", value: "$700", tint: Colors.sky)
                mockMetricCell(label: "Spent", value: "$460", tint: Colors.rose)
            }
        }
    }

    private func snapshotMockContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your budget is in good shape. Room for occasional treats without stress.")
                .font(.subheadline)
                .foregroundStyle(primaryLabel)
            Text("We'll surface patterns and suggest small tweaks to stretch your budget.")
                .font(.caption)
                .foregroundStyle(secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func affordMockContent() -> some View {
        Text("Type any purchase to see how it affects your budget before you buy.")
            .font(.subheadline)
            .foregroundStyle(secondaryLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stayOnTrackMockContent() -> some View {
        Text("Savings goals, spending alerts, and a clear view of how you're doing each month.")
            .font(.subheadline)
            .foregroundStyle(secondaryLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mockMetricCell(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(secondaryLabel)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.2), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var setupContent: some View {
        OnboardingSetupView(
            profile: $draftProfile,
            currentStep: .constant(setupStep),
            colorScheme: colorScheme
        )
    }
}

struct OnboardingButtonStyle: ButtonStyle {
    var accent: Color = Colors.mint
    var isFilled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isFilled ? accent : Color.clear,
                in: Capsule()
            )
            .foregroundStyle(isFilled ? .white : accent)
            .overlay(
                Capsule()
                    .stroke(isFilled ? Color.clear : accent, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.smooth(duration: 0.15), value: configuration.isPressed)
    }
}

enum SetupStep: Int, CaseIterable {
    case profile, income, housing, food, expenses, goals
}

private func isWizardStepComplete(profile: StudentProfile, step: SetupStep) -> Bool {
    switch step {
    case .profile:
        return !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !profile.school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .income:
        return profile.monthlyIncome >= 0 && profile.savings >= 0 && profile.tuition >= 0 && profile.scholarshipsAid >= 0
    case .housing:
        switch profile.housingType {
        case .onCampus: return profile.rent >= 0
        case .offCampus: return profile.rent >= 0 && profile.utilities >= 0
        case .commuter: return true
        }
    case .food:
        return profile.mealPlan >= 0 && profile.groceries >= 0
    case .expenses:
        return profile.transportation >= 0 && profile.subscriptions >= 0 && profile.personal >= 0
    case .goals:
        return profile.savingsGoal >= 0 && profile.investments >= 0
    }
}

struct OnboardingSetupView: View {
    @Binding var profile: StudentProfile
    @Binding var currentStep: SetupStep
    var colorScheme: ColorScheme

    @State private var termSeason: String = "Spring"
    @State private var termYear: Int = Calendar.current.component(.year, from: Date())

    private var primaryLabel: Color { colorScheme == .dark ? .white : .primary }
    private var secondaryLabel: Color { colorScheme == .dark ? .white.opacity(0.84) : Color.primary.opacity(0.68) }
    private var tertiaryLabel: Color { colorScheme == .dark ? .white.opacity(0.72) : Color.primary.opacity(0.58) }
    private var inputBg: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.9)
    }
    private var inputText: Color { colorScheme == .dark ? .white : .primary }
    private var inputStroke: Color { Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.08) }

    private let gridSpacing: CGFloat = 16
    private let sectionSpacing: CGFloat = 24
    private let horizontalPadding: CGFloat = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                switch currentStep {
                case .profile: profileStep
                case .income: incomeStep
                case .housing: housingStep
                case .food: foodStep
                case .expenses: expensesStep
                case .goals: goalsStep
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1))
            .padding(horizontalPadding)
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            let parts = profile.term.split(separator: " ")
            if let first = parts.first { termSeason = String(first) }
            if let last = parts.last, let y = Int(last) { termYear = y }
        }
        .onChange(of: termSeason) { _, _ in profile.term = "\(termSeason) \(termYear)" }
        .onChange(of: termYear) { _, _ in profile.term = "\(termSeason) \(termYear)" }
        .onChange(of: profile.housingType) { _, newType in
            if newType == .commuter { profile.utilities = 0; profile.rent = 0 }
        }
    }

    private func sectionHeader(icon: String, title: String, subtitle: String? = nil, accent: Color = Colors.mint) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(accent)
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(primaryLabel)
                    .multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(secondaryLabel)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private func sectionTitle(_ title: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(primaryLabel)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(secondaryLabel)
            }
        }
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            VStack(spacing: 8) {
                Text("Who are you?")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(primaryLabel)
                    .frame(maxWidth: .infinity)
                Text("We'll use this to personalize your budget and insights. Tell us a bit about yourself.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryLabel)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 4)

            AvatarPickerView(profile: $profile, labelColor: primaryLabel)
                .frame(maxWidth: .infinity)

            formField(label: "Name", hint: "Your full name — how we'll refer to you in the app") {
                LabeledField("", value: $profile.name, placeholder: "Your full name", labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "School", hint: "University or college you attend") {
                LabeledField("", value: $profile.school, placeholder: "University or college", labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Expected graduation", hint: "Spring, Summer, Fall, or Winter and year") {
                HStack(spacing: 12) {
                    Picker("Term", selection: $termSeason) {
                        Text("Spring").tag("Spring")
                        Text("Summer").tag("Summer")
                        Text("Fall").tag("Fall")
                        Text("Winter").tag("Winter")
                    }
                    .pickerStyle(.menu)
                    .tint(inputText)
                    Picker("Year", selection: $termYear) {
                        ForEach(yearRange, id: \.self) { Text(String($0)).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(inputText)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(inputBg))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(inputStroke, lineWidth: 1))
            }
        }
    }

    private var incomeStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            sectionHeader(icon: "dollarsign.circle.fill", title: "Financial Details", subtitle: "Your income and school costs drive your budget. Enter amounts per month.", accent: Colors.mint)
            formField(label: "Monthly savings", hint: "Contribution from your savings each month") {
                LabeledNumberField("", value: $profile.savings, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Monthly income", hint: "Jobs, side gigs, allowance — what you actually take in each month") {
                LabeledNumberField("", value: $profile.monthlyIncome, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Tuition", hint: "Total tuition per month (Per semester / 4)") {
                LabeledNumberField("", value: $profile.tuition, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Scholarships & aid", hint: "Financial aid, grants, or scholarships applied per month") {
                LabeledNumberField("", value: $profile.scholarshipsAid, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
        }
    }

    private var housingStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            sectionHeader(icon: "house.fill", title: "Where you live", subtitle: "Housing affects a big part of your budget. Choose your situation so we can label costs correctly — dorms, rent, or commuting from home.", accent: Colors.peach)
            formField(label: "Housing type", hint: "On-campus (dorm), off-campus (apartment/house), or commuter (living at home)") {
                Picker("Housing type", selection: $profile.housingType) {
                    Text("On-Campus").tag(BudgetInput.HousingType.onCampus)
                    Text("Off-Campus").tag(BudgetInput.HousingType.offCampus)
                    Text("Commuter").tag(BudgetInput.HousingType.commuter)
                }
                .pickerStyle(.segmented)
                .tint(Colors.peach)
            }

            switch profile.housingType {
            case .onCampus:
                formField(label: "Dorm", hint: "Monthly cost for room and board or university housing. Utilities are usually included.") {
                    LabeledNumberField("", value: $profile.rent, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
                }
            case .offCampus:
                formField(label: "Rent", hint: "Monthly rent for your apartment or house") {
                    LabeledNumberField("", value: $profile.rent, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
                }
                formField(label: "Utilities", hint: "Electric, water, internet, etc. — monthly total") {
                    LabeledNumberField("", value: $profile.utilities, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
                }
            case .commuter:
                Text("You're living at home — we won't ask for rent or utilities. Add any household contribution you make in \"Other monthly spending\" if you like.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryLabel)
            }
        }
    }

    private var foodStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            sectionHeader(icon: "fork.knife", title: "Food", subtitle: "Food is one of the easiest categories to overspend. Setting a number here helps you stay on track.", accent: Colors.sun)
            formField(label: "Meal plan", hint: "Campus dining plan cost per month — enter 0 if you don't have one") {
                LabeledNumberField("", value: $profile.mealPlan, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Groceries", hint: "Stores, restaurants, delivery — what you spend on food outside the meal plan") {
                LabeledNumberField("", value: $profile.groceries, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
        }
    }

    private var expensesStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            sectionHeader(icon: "creditcard.fill", title: "Other monthly spending", subtitle: "Transportation, subscriptions, and personal spending round out your budget. Estimate what you typically spend or plan to spend.", accent: Colors.lavender)
            formField(label: "Transportation", hint: "Gas, transit passes, rideshare — getting around each month") {
                LabeledNumberField("", value: $profile.transportation, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Subscriptions", hint: "Streaming, music, gym, apps — monthly total") {
                LabeledNumberField("", value: $profile.subscriptions, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Personal & entertainment", hint: "Clothing, hobbies, going out, anything else you budget for") {
                LabeledNumberField("", value: $profile.personal, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
        }
    }

    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            sectionHeader(icon: "target", title: "Goals & planning style", subtitle: "Set a savings goal and choose whether you like to plan by month or by semester. You can change this later.", accent: Colors.pistachio)
            formField(label: "Monthly savings goal", hint: "How much you want to put away each month — we'll help you see if you're on track") {
                LabeledNumberField("", value: $profile.savingsGoal, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Monthly investments", hint: "Stocks, crypto, or other investments — enter 0 if you don't invest yet") {
                LabeledNumberField("", value: $profile.investments, isCurrency: true, labelColor: secondaryLabel, textColor: inputText, backgroundColor: inputBg, cornerRadius: 16, strokeColor: inputStroke)
            }
            formField(label: "Planning style", hint: "Monthly: track week by week. Semester: plan around tuition and term dates.") {
                Picker("Planning style", selection: $profile.budgetStyle) {
                    Text("Per Month").tag(BudgetInput.BudgetStyle.monthly)
                    Text("Per Semester").tag(BudgetInput.BudgetStyle.semester)
                }
                .pickerStyle(.segmented)
                .tint(Colors.pistachio)
            }
        }
    }

    private func formField<Content: View>(label: String, hint: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(primaryLabel)
            Text(hint)
                .font(.caption)
                .foregroundStyle(secondaryLabel)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var yearRange: [Int] {
        let y = Calendar.current.component(.year, from: Date())
        return Array((y - 2)...(y + 6))
    }
}
