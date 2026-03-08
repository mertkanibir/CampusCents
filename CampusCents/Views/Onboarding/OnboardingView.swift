import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var page = 0
    @State private var draftProfile: StudentProfile = .sample

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $page) {
                OnboardingPage(
                    title: "Welcome to CampusCents",
                    subtitle: "A beautiful, smart budgeting companion for student life.",
                    icon: "graduationcap.fill",
                    tint: Colors.sky
                )
                .tag(0)

                OnboardingPage(
                    title: "Track, plan, and decide",
                    subtitle: "See where your money goes and get real-time affordability guidance.",
                    icon: "sparkles",
                    tint: Colors.rose
                )
                .tag(1)

                ProfileQuickSetupView(profile: $draftProfile)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(page < 2 ? "Continue" : "Get Started") {
                if page < 2 {
                    page += 1
                } else {
                    state.completeOnboarding(with: draftProfile)
                }
            }
            .buttonStyle(MainButtonStyle())
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(.white)
                .padding(26)
                .background(tint, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 12, y: 8)
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}

struct ProfileQuickSetupView: View {
    @Binding var profile: StudentProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                AvatarPickerView(profile: $profile)

                GroupBox("Profile") {
                    VStack(spacing: 10) {
                        LabeledField("Name", value: $profile.name)
                        LabeledField("School", value: $profile.school)
                        LabeledField("Term", value: $profile.term)
                    }
                    .padding(.top, 4)
                }

                GroupBox("Monthly Budget") {
                    VStack(spacing: 10) {
                        LabeledNumberField("Income", value: $profile.monthlyIncome)
                        LabeledNumberField("Rent", value: $profile.rent)
                        LabeledNumberField("Utilities", value: $profile.utilities)
                        LabeledNumberField("Meal Plan", value: $profile.mealPlan)
                        LabeledNumberField("Groceries", value: $profile.groceries)
                        LabeledNumberField("Transportation", value: $profile.transportation)
                        LabeledNumberField("Subscriptions", value: $profile.subscriptions)
                        LabeledNumberField("Personal", value: $profile.personal)
                        LabeledNumberField("Savings Goal", value: $profile.savingsGoal)

                        Picker("Budget Style", selection: $profile.budgetStyle) {
                            ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Housing Type", selection: $profile.housingType) {
                            ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
        }
    }
}
