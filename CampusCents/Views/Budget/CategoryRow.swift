import SwiftUI

struct CategoryRow: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let category: BudgetCategory
    @State private var budgetText = ""

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(category.name, systemImage: category.kind.icon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(primaryText)

                    if let desc = category.kind.desc, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(secondaryText)
                            .padding(.leading, 24)
                    }
                }
                Spacer()
                Text("\(category.spent.currency) / \(category.budget.currency)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(secondaryText)
            }

            ProgressView(value: category.spent / max(category.budget, 1))
                .tint(category.kind.tint)

            HStack(spacing: 10) {
                TextField("Set budget", text: $budgetText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .font(.body.weight(.medium))
                    .foregroundStyle(primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.9))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.08), lineWidth: 1)
                    }

                Button("Update") {
                    if let value = Double(budgetText.replacingOccurrences(of: ",", with: ".")) {
                        state.updateBudget(for: category.kind, value: value)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? primaryText : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Colors.periwinkle, in: Capsule())
                .buttonStyle(.plain)

                let essentialKinds: [BudgetCategory.Kind] = [.income, .investment, .tuition, .rent, .groceries, .subscriptions, .personal]
                if !essentialKinds.contains(category.kind) {
                    Button {
                        withAnimation {
                            state.removeCategory(category)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(secondaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(category.kind.tint.opacity(colorScheme == .dark ? 0.2 : 0.1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(category.kind.tint.opacity(colorScheme == .dark ? 0.4 : 0.25), lineWidth: 1)
        }
        .onAppear {
            budgetText = String(format: "%.0f", category.budget)
        }
    }
}
