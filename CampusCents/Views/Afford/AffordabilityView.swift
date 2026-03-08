import SwiftUI

struct AffordabilityView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var itemName = "Coffee with friends"
    @State private var priceText = "12"
    @State private var showScenarioSheet = false
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

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Purchase Simulator")
                                    .font(.title3.weight(.bold))
                                Text("Enter an item and price to see how it fits into your current monthly budget.")
                                    .font(.subheadline)
                                    .foregroundStyle(secondaryText)
                            }
                            Spacer()
                            Button {
                                showScenarioSheet = true
                            } label: {
                                Label("Compare", systemImage: "sparkles.rectangle.stack")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.35 : 0.14), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Colors.periwinkle)
                        }

                        VStack(spacing: 14) {
                            inputField(
                                title: "Item",
                                systemImage: "shippingbox.fill",
                                placeholder: "Coffee with friends",
                                value: $itemName
                            )
                            inputField(
                                title: "Price",
                                systemImage: "dollarsign.circle.fill",
                                placeholder: "12",
                                value: $priceText,
                                keyboardType: .decimalPad
                            )
                        }

                        HStack(spacing: 12) {
                            statPill(
                                title: "Flexible Budget",
                                value: discretionaryBudget.currency,
                                detail: "Personal + groceries",
                                tint: Colors.blueMint
                            )
                            statPill(
                                title: "Purchase Share",
                                value: purchaseShareText,
                                detail: "Percent of flexible budget",
                                tint: accentColor
                            )
                        }

                        explainerBox(
                            title: "How this works",
                            points: [
                                "We compare the entered price against your flexible budget, which currently includes your personal and grocery spending buckets.",
                                "A smaller purchase share means the item is easier to absorb without changing the rest of your plan.",
                                "The AI insight below explains the likely budget impact, but it is still a guide, not a guarantee."
                            ]
                        )
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(surfaceBackground, in: RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: primaryCardCornerRadius, style: .continuous)
                            .stroke(surfaceStroke, lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.08), radius: 18, y: 10)

                    ResultCard(result: evaluation)
                    ImpactCard(itemName: itemName, priceText: priceText)

                    quickContextCard
                }
                .padding()
            }
            .overlay(alignment: .top) { TopSafeAreaGradientOverlay() }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showScenarioSheet) {
                ScenarioSheet()
                    .environmentObject(state)
            }
        }
    }

    private var evaluation: AffordabilityResult {
        let ratio = parsedPrice / max(1, discretionaryBudget)

        switch ratio {
        case ..<0.1:
            return .safe("This purchase has very low impact on your monthly plan.")
        case ..<0.25:
            return .mostlySafe("Reasonable choice. Keep an eye on repeated buys.")
        case ..<0.5:
            return .risky("This is meaningful for your current discretionary budget.")
        default:
            return .no("This has high budget impact unless another category is adjusted.")
        }
    }

    private var parsedPrice: Double {
        Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var discretionaryBudget: Double {
        state.profile.personal + state.profile.groceries
    }

    private var purchaseShareText: String {
        let share = (parsedPrice / max(1, discretionaryBudget)) * 100
        return "\(Int(share.rounded()))%"
    }

    private var accentColor: Color {
        switch evaluation {
        case .safe: Colors.mint
        case .mostlySafe: Colors.sky
        case .risky: Colors.sun
        case .no: Colors.rose
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
                    Text("Check if a purchase fits before you buy.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("This screen turns one price into a quick budget-fit read, then adds an AI explanation so the result is easier to understand.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    metricTile(title: "Remaining", value: state.remaining.currency, tint: Colors.mint)
                    metricTile(title: "Tracked Spend", value: state.spent.currency, tint: Colors.periwinkle)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: Colors.periwinkle.opacity(colorScheme == .dark ? 0.2 : 0.14), radius: 20, y: 10)
    }

    private var quickContextCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Quick Context", systemImage: "waveform.path.ecg.rectangle")
                    .font(.headline.weight(.semibold))
                Spacer()
                Text(state.profile.budgetStyle.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Colors.blueMint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Colors.blueMint.opacity(colorScheme == .dark ? 0.26 : 0.12), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 10) {
                contextRow(title: "Remaining monthly budget", value: state.remaining.currency)
                contextRow(title: "Personal + groceries budget", value: discretionaryBudget.currency)
                contextRow(title: "Housing mode", value: state.profile.housingType.displayName)
            }

            Capsule(style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.06))
                .frame(height: 1)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Colors.blueMint)
                    .padding(.top, 2)

                Text("These values come from your saved profile and explain what the affordability result is based on.")
                    .font(.caption)
                    .foregroundStyle(quietText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(surfaceBackground, in: RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: secondaryCardCornerRadius, style: .continuous)
                .stroke(surfaceStroke, lineWidth: 1)
        }
    }

    private var surfaceBackground: some ShapeStyle {
        Colors.cardFill(for: colorScheme)
    }

    private var surfaceStroke: Color {
        Colors.cardStroke(for: colorScheme)
    }

    private func metricTile(title: String, value: String, tint: Color) -> some View {
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

    private func statPill(title: String, value: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tertiaryText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(colorScheme == .dark ? primaryText : tint)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(quietText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(colorScheme == .dark ? 0.24 : 0.09), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .dark ? 0.48 : 0.2), lineWidth: 1)
        }
    }

    private func explainerBox(title: String, points: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(primaryText)

            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Colors.periwinkle)
                        .padding(.top, 2)
                    Text(point)
                        .font(.caption)
                        .foregroundStyle(tertiaryText)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.06), lineWidth: 1)
        }
    }

    private func inputField(
        title: String,
        systemImage: String,
        placeholder: String,
        value: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tertiaryText)

            TextField(placeholder, text: value)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .font(.body.weight(.medium))
                .foregroundStyle(primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.9))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.08), lineWidth: 1)
                }
        }
    }

    private func contextRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(secondaryText)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(primaryText)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
