import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme

    var prefill: TransactionTemplate?

    @State private var title = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category: BudgetCategory.Kind = .groceries

    private let cardCornerRadius: CGFloat = 24

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58)
    }

    init(prefill: TransactionTemplate? = nil) {
        self.prefill = prefill
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    suggestionsCard
                    formCard
                }
                .padding()
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let prefill {
                    apply(prefill)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Suggestions (templates; tap to prefill)
    private var suggestionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggestions")
                .font(.headline.weight(.semibold))
                .foregroundStyle(primaryText)
            Text("Tap one to fill the form.")
                .font(.subheadline)
                .foregroundStyle(secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(state.templates) { template in
                        Button {
                            apply(template)
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
                            .background(
                                Colors.cardFill(for: colorScheme),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
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
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
    }

    // MARK: - Form card (same input style as Afford / Insights)
    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction")
                .font(.title3.weight(.bold))
                .foregroundStyle(primaryText)

            VStack(alignment: .leading, spacing: 8) {
                Label("Title", systemImage: "textformat")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tertiaryText)
                TextField("e.g. Coffee, Groceries", text: $title)
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

            VStack(alignment: .leading, spacing: 8) {
                Label("Amount", systemImage: "dollarsign.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tertiaryText)
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
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

            VStack(alignment: .leading, spacing: 8) {
                Label("Date", systemImage: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tertiaryText)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Colors.periwinkle)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Category", systemImage: "folder.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tertiaryText)
                Picker("Category", selection: $category) {
                    ForEach(state.categories.filter { $0.kind != .aid }, id: \.id) { cat in
                        Label(cat.kind.displayName, systemImage: cat.kind.icon)
                            .tag(cat.kind)
                    }
                }
                .pickerStyle(.menu)
                .tint(primaryText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private func apply(_ template: TransactionTemplate) {
        title = template.title
        amountText = template.amount == floor(template.amount) ? String(Int(template.amount)) : String(template.amount)
        date = Date()
        category = template.category
    }

    private func save() {
        let value = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, value > 0 else { return }
        state.addTransaction(title: trimmed, amount: value, date: date, category: category)
        dismiss()
    }
}
