import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var page = 0
    @State private var draftProfile: StudentProfile = .sample

    private static let onboardingBackground = Color(red: 0, green: 90/255, blue: 67/255) // #005A43

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $page) {
                OnboardingPage(
                    title: "Welcome to CampusCents",
                    subtitle: "An intelligent budgeting app for college students.",
                    tint: Colors.pistachio,
                    customImage: "CampusCentsIcon"
                )
                .tag(0)

                OnboardingPage(
                    title: "Track, plan, and know",
                    subtitle: "Track spending, plan your budget, and get real-time insights",
                    icon: "sparkles",
                    tint: Colors.pistachio
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
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Self.onboardingBackground)
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
            .background(Color.white.opacity(configuration.isPressed ? 0.9 : 1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        VStack(spacing: 20) {
            Spacer()
            Group {
                if let name = customImage {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 240)
                        .clipped()
                } else if let sfIcon = icon {
                    Image(systemName: sfIcon)
                        .font(.system(size: 58, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    EmptyView()
                }
            }
            .padding(26)
            .background(customImage != nil ? Color.clear : tint, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 12, y: 8)
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}

struct ProfileQuickSetupView: View {
    @Binding var profile: StudentProfile

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.top, 8)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                AvatarPickerView(profile: $profile)
                    .foregroundStyle(.white)

                sectionHeader("Profile")
                VStack(spacing: 10) {
                    LabeledField("Name", value: $profile.name, labelColor: .white)
                    LabeledField("School", value: $profile.school, labelColor: .white)
                    LabeledField("Term", value: $profile.term, labelColor: .white)
                }

                sectionHeader("Income")
                VStack(spacing: 10) {
                    LabeledNumberField("Income", value: $profile.monthlyIncome, labelColor: .white)
                }
                LabeledNumberField("Investments", value: $profile.investments, labelColor: .white)

                sectionHeader("Housing")
                VStack(spacing: 10) {
                    LabeledNumberField("Rent", value: $profile.rent, labelColor: .white)
                    LabeledNumberField("Utilities", value: $profile.utilities, labelColor: .white)
                    Picker("Housing Type", selection: $profile.housingType) {
                        ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                sectionHeader("Food")
                VStack(spacing: 10) {
                    LabeledNumberField("Meal Plan", value: $profile.mealPlan, labelColor: .white)
                    LabeledNumberField("Groceries", value: $profile.groceries, labelColor: .white)
                }

                sectionHeader("Other Expenses")
                VStack(spacing: 10) {
                    LabeledNumberField("Transportation", value: $profile.transportation, labelColor: .white)
                    LabeledNumberField("Subscriptions", value: $profile.subscriptions, labelColor: .white)
                    LabeledNumberField("Personal", value: $profile.personal, labelColor: .white)
                }

                sectionHeader("Goals & Preferences")
                VStack(spacing: 10) {
                    LabeledNumberField("Savings Goal", value: $profile.savingsGoal, labelColor: .white)
                    Picker("Budget Style", selection: $profile.budgetStyle) {
                        ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
            .foregroundStyle(.white)
            .tint(.white)
        }
        .scrollContentBackground(.hidden)
    }
}
