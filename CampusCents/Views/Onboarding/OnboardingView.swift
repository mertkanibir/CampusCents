import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var page = 0
    @State private var draftProfile: StudentProfile = .sample
    @State private var wizardStep: SetupStep = .profile

    private static let onboardingBackground = Color(red: 0, green: 90/255, blue: 67/255) // #005A43

    var body: some View {
        VStack(spacing: 0) {
            // Page content (conditional to prevent swipe-back) — only the content slides
            Group {
                switch page {
                case 0:
                    OnboardingPage(
                        title: "Welcome to CampusCents",
                        subtitle: "An intelligent budgeting app for college students.",
                        tint: Colors.pistachio,
                        customImage: "CampusCentsIcon"
                    )
                case 1:
                    OnboardingPage(
                        title: "Track, plan, and know",
                        subtitle: "Track spending, plan your budget, and get real-time insights",
                        icon: "sparkles",
                        tint: Colors.pistachio
                    )
                default:
                    ProfileQuickSetupView(profile: $draftProfile, currentStep: $wizardStep, showNavBar: false) {
                        state.completeOnboarding(with: draftProfile)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(page)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))

            // 3-dot page indicator (intro pages only)
            if page < 2 {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == page ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 12)
            }

            // Continue button (intro pages)
            if page < 2 {
                Button("Continue") {
                    withAnimation(.smooth(duration: 0.4)) {
                        page += 1
                    }
                }
                .buttonStyle(OnboardingButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }

            // Wizard progress + buttons (profile setup) — appear in place like Continue
            if page == 2 {
                WizardNavBarView(
                    profile: $draftProfile,
                    currentStep: $wizardStep
                ) {
                    state.completeOnboarding(with: draftProfile)
                }
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Self.onboardingBackground)
        .animation(.smooth(duration: 0.4), value: page)
        .onChange(of: page) { _, newPage in
            if newPage == 2 {
                wizardStep = .profile
            }
        }
    }
}

struct OnboardingButtonStyle: ButtonStyle {
    private static let green = Color(red: 0, green: 90/255, blue: 67/255) // #005A43

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Self.green)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(configuration.isPressed ? 0.9 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.smooth(duration: 0.15), value: configuration.isPressed)
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    var icon: String? = nil
    let tint: Color
    var customImage: String? = nil

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Group {
                if let name = customImage {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                } else if let sfIcon = icon {
                    Image(systemName: sfIcon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white)
                } else {
                    EmptyView()
                }
            }
            .padding(28)
            .background(customImage != nil ? Color.clear : tint, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 16, y: 6)

            VStack(spacing: 10) {
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .padding(.vertical, 24)
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
        return profile.monthlyIncome > 0
    case .housing:
        return profile.rent >= 0 && profile.utilities >= 0
    case .food:
        return profile.mealPlan >= 0 && profile.groceries >= 0
    case .expenses:
        return profile.transportation >= 0 && profile.subscriptions >= 0 && profile.personal >= 0
    case .goals:
        return profile.savingsGoal >= 0 && profile.investments >= 0
    }
}

struct WizardNavBarView: View {
    @Binding var profile: StudentProfile
    @Binding var currentStep: SetupStep
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(SetupStep.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                        .frame(height: 3)
                        .animation(.smooth(duration: 0.25), value: currentStep)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 12)

            HStack(spacing: 12) {
                if currentStep != .profile {
                    Button {
                        if let prev = SetupStep(rawValue: currentStep.rawValue - 1) {
                            withAnimation(.smooth(duration: 0.25)) { currentStep = prev }
                        }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    .frame(width: 100)
                }

                if currentStep == .goals {
                    Button("Get Started") {
                        onComplete()
                    }
                    .buttonStyle(OnboardingButtonStyle())
                } else {
                    Button("Next") {
                        if let next = SetupStep(rawValue: currentStep.rawValue + 1) {
                            withAnimation(.smooth(duration: 0.25)) { currentStep = next }
                        }
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    .disabled(!isWizardStepComplete(profile: profile, step: currentStep))
                    .opacity(isWizardStepComplete(profile: profile, step: currentStep) ? 1 : 0.6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .foregroundStyle(.white)
        .tint(.white)
    }
}

struct ProfileQuickSetupView: View {
    @Binding var profile: StudentProfile
    @Binding var currentStep: SetupStep
    var showNavBar: Bool = true
    var onComplete: (() -> Void)? = nil

    @State private var termSeason: String = "Spring"
    @State private var termYear: Int = Calendar.current.component(.year, from: Date())

    private static let green = Color(red: 0, green: 90/255, blue: 67/255) // #005A43
    private static let textBoxGreen = Color(red: 11/255, green: 68/255, blue: 50/255) // #0B4432

    init(profile: Binding<StudentProfile>, currentStep: Binding<SetupStep>, showNavBar: Bool = true, onComplete: (() -> Void)? = nil) {
        self._profile = profile
        self._currentStep = currentStep
        self.showNavBar = showNavBar
        self.onComplete = onComplete
    }

    private var stepContentPadding: EdgeInsets {
        EdgeInsets(top: 20, leading: 24, bottom: 24, trailing: 24)
    }

    private var isCurrentStepComplete: Bool {
        switch currentStep {
        case .profile:
            return !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !profile.school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .income:
            return profile.monthlyIncome > 0
        case .housing:
            return profile.rent >= 0 && profile.utilities >= 0
        case .food:
            return profile.mealPlan >= 0 && profile.groceries >= 0
        case .expenses:
            return profile.transportation >= 0 && profile.subscriptions >= 0 && profile.personal >= 0
        case .goals:
            return profile.savingsGoal >= 0 && profile.investments >= 0
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
    }

    private var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 2)...(currentYear + 6))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Group {
                    switch currentStep {
                    case .profile: profileStepContent
                    case .income: incomeStepContent
                    case .housing: housingStepContent
                    case .food: foodStepContent
                    case .expenses: expensesStepContent
                    case .goals: goalsStepContent
                    }
                }
                .id(currentStep)
            }
            .scrollContentBackground(.hidden)
            .environment(\.colorScheme, .light)

            if showNavBar {
                // Progress indicator (above button)
                HStack(spacing: 8) {
                    ForEach(SetupStep.allCases, id: \.rawValue) { step in
                        Capsule()
                            .fill(step.rawValue <= currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                            .frame(height: 3)
                            .animation(.smooth(duration: 0.25), value: currentStep)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Bottom navigation
                HStack(spacing: 12) {
                    if currentStep != .profile {
                        Button {
                            if let prev = SetupStep(rawValue: currentStep.rawValue - 1) {
                                withAnimation(.smooth(duration: 0.25)) { currentStep = prev }
                            }
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .buttonStyle(OnboardingButtonStyle())
                        .frame(width: 100)
                    }

                    if currentStep == .goals {
                        Button("Get Started") {
                            onComplete?()
                        }
                        .buttonStyle(OnboardingButtonStyle())
                    } else {
                        Button("Next") {
                            if let next = SetupStep(rawValue: currentStep.rawValue + 1) {
                                withAnimation(.smooth(duration: 0.25)) { currentStep = next }
                            }
                        }
                        .buttonStyle(OnboardingButtonStyle())
                        .disabled(!isCurrentStepComplete)
                        .opacity(isCurrentStepComplete ? 1 : 0.6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
        .foregroundStyle(.white)
        .tint(.white)
        .onAppear {
            let parts = profile.term.split(separator: " ")
            if let first = parts.first {
                termSeason = String(first)
            }
            if let last = parts.last, let y = Int(last) {
                termYear = y
            }
        }
        .onChange(of: termSeason) { _, _ in updateTerm() }
        .onChange(of: termYear) { _, _ in updateTerm() }
    }

    private func updateTerm() {
        profile.term = "\(termSeason) \(termYear)"
    }

    private var profileStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            AvatarPickerView(profile: $profile)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            sectionHeader("Profile")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledField("Name", value: $profile.name, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledField("School", value: $profile.school, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Graduation")
                        .font(.footnote)
                        .foregroundStyle(.white)
                    HStack(spacing: 12) {
                        Picker("Season", selection: $termSeason) {
                            Text("Spring").tag("Spring")
                            Text("Fall").tag("Fall")
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        Picker("Year", selection: $termYear) {
                            ForEach(yearRange, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Self.textBoxGreen))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }

    private var incomeStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Income")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledNumberField("Income", value: $profile.monthlyIncome, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }

    private var housingStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Housing")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledNumberField("Rent", value: $profile.rent, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledNumberField("Utilities", value: $profile.utilities, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Housing Type")
                        .font(.footnote)
                        .foregroundStyle(.white)
                    Picker("Housing Type", selection: $profile.housingType) {
                        ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }

    private var foodStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Food")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledNumberField("Meal Plan", value: $profile.mealPlan, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledNumberField("Groceries", value: $profile.groceries, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }

    private var expensesStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Other Expenses")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledNumberField("Transportation", value: $profile.transportation, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledNumberField("Subscriptions", value: $profile.subscriptions, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledNumberField("Personal", value: $profile.personal, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }

    private var goalsStepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Goals & Preferences")
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 16) {
                LabeledNumberField("Savings Goal", value: $profile.savingsGoal, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                LabeledNumberField("Investments", value: $profile.investments, labelColor: .white, textColor: .white, backgroundColor: Self.textBoxGreen)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Style")
                        .font(.footnote)
                        .foregroundStyle(.white)
                    Picker("Budget Style", selection: $profile.budgetStyle) {
                        ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(stepContentPadding)
    }
}
