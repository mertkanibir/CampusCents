import SwiftUI

struct AddTabView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddSheet = false
    @State private var addSheetPrefill: TransactionTemplate?
    @State private var showingRecurringSheet = false

    // AI add-with-text
    @State private var aiInputText = ""
    @State private var parsedInput: ParsedTransactionInput?
    @State private var isParsing = false
    @State private var aiService = AIService()

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

    private var categoryKeysForAI: [String] {
        state.categories.filter { $0.kind != .aid }.map { $0.kind.kindKey }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard
                    addWithAICard
                    addTransactionButtonCard
                    suggestionsSection
                    recurringSection
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionView(prefill: addSheetPrefill)
                    .environmentObject(state)
                    .onDisappear { addSheetPrefill = nil }
            }
            .sheet(isPresented: $showingRecurringSheet) {
                AddRecurringView()
                    .environmentObject(state)
            }
        }
    }

    // MARK: - Hero card (same style as Afford / Insights)
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
                    Text("Log expenses in seconds.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Type what you spent in plain language, use a suggestion, or tap Add transaction to fill the form.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    heroMetricTile(title: "This month", value: state.spent.currency, tint: Colors.periwinkle)
                    heroMetricTile(title: "Remaining", value: state.remaining.currency, tint: Colors.mint)
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

    // MARK: - Add with AI card
    private var addWithAICard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Add with AI", systemImage: "sparkles")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(primaryText)
                Spacer()
            }

            TextField("e.g. Coffee $5, Groceries 35", text: $aiInputText)
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
                .onSubmit { Task { await parseAndShow() } }
                .disabled(isParsing)

            if isParsing {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Parsing…")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
            } else if let parsed = parsedInput, parsed.amount > 0 {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(parsed.transactionTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(primaryText)
                        HStack(spacing: 6) {
                            Text(parsed.amount.currency)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(secondaryText)
                            Text("·")
                                .font(.caption)
                                .foregroundStyle(tertiaryText)
                            Text(parsed.dateLabel())
                                .font(.caption)
                                .foregroundStyle(secondaryText)
                        }
                    }
                    Spacer()
                    Button {
                        applyParsedAndAdd(parsed)
                        aiInputText = ""
                        parsedInput = nil
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Colors.periwinkle, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Button {
                Task { await parseAndShow() }
            } label: {
                Label("Parse with AI", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.3 : 0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(colorScheme == .dark ? primaryText : Colors.periwinkle)
            .disabled(aiInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isParsing)
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

    // MARK: - Main Add transaction button (prettier, prominent)
    private var addTransactionButtonCard: some View {
        Button {
            addSheetPrefill = nil
            showingAddSheet = true
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
                    Text("Add transaction")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(primaryText)
                    Text("Title, amount, date & category")
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

    // MARK: - Suggestions (templates; tap opens add sheet with prefill)
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggestions")
                .font(.title3.weight(.bold))
                .foregroundStyle(primaryText)
            Text("Tap to add with one tap.")
                .font(.subheadline)
                .foregroundStyle(secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(state.templates) { template in
                        Button {
                            addSheetPrefill = template
                            showingAddSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: template.category.icon)
                                    .font(.subheadline)
                                    .foregroundStyle(template.category.tint)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                        .foregroundStyle(primaryText)
                                    Text(template.amount.currency)
                                        .font(.caption)
                                        .foregroundStyle(secondaryText)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Recurring (same content, consistent card style)
    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recurring")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(primaryText)
                    Text("Add or trigger recurring expenses.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
                Spacer()
                Button {
                    showingRecurringSheet = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.35 : 0.14), in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(colorScheme == .dark ? primaryText : Colors.periwinkle)
            }

            if state.recurring.isEmpty {
                Text("No recurring expenses. Tap Add to create one.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(state.recurring) { rec in
                        recurringRow(rec)
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
    }

    private func recurringRow(_ rec: RecurringTransaction) -> some View {
        HStack(spacing: 10) {
            Image(systemName: rec.category.icon)
                .foregroundStyle(.white)
                .padding(8)
                .background(rec.category.tint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(rec.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(primaryText)
                Text("\(rec.frequency.displayName) · Next: \(rec.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(secondaryText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(rec.amount.currency)
                    .font(.subheadline.bold())
                    .foregroundStyle(primaryText)
                HStack(spacing: 8) {
                    Button("Add now") {
                        state.addOccurrence(for: rec)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Colors.periwinkle)
                    Button {
                        state.removeRecurring(rec)
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(secondaryText)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.03), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Actions
    private func parseAndShow() async {
        let text = aiInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isParsing = true
        parsedInput = nil
        let keys = categoryKeysForAI
        if keys.isEmpty {
            parsedInput = await aiService.parseTransaction(from: text, categoryKeys: ["personal", "groceries", "transportation", "mealPlan", "rent", "utilities", "subscriptions", "tuition", "investment"])
        } else {
            parsedInput = await aiService.parseTransaction(from: text, categoryKeys: keys)
        }
        isParsing = false
    }

    private func applyParsedAndAdd(_ parsed: ParsedTransactionInput) {
        let kind: BudgetCategory.Kind = BudgetCategory.Kind.kind(forKey: parsed.categoryKey)
            ?? state.categories.first(where: { $0.kind.kindKey == parsed.categoryKey })?.kind
            ?? .personal
        let date = parsed.resolvedDate()
        state.addTransaction(title: parsed.transactionTitle, amount: parsed.amount, date: date, category: kind)
    }
}
