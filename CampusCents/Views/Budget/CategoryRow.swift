import SwiftUI

struct CategoryRow: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let category: BudgetCategory
    @State private var budgetText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(category.name, systemImage: category.kind.icon)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .primary)
                Spacer()
                Text("\(category.spent.currency) / \(category.budget.currency)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: category.spent / max(category.budget, 1))
                .tint(category.kind.tint)

            HStack(spacing: 8) {
                TextField("Set budget", text: $budgetText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                
                Button("Update") {
                    if let value = Double(budgetText.replacingOccurrences(of: ",", with: ".")) {
                        state.updateBudget(for: category.kind, value: value)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(category.kind.tint)
                
                let essentialKinds: [BudgetCategory.Kind] = [.income, .investment, .tuition, .rent, .groceries, .subscriptions, .personal]
                if !essentialKinds.contains(category.kind) {
                    Button(role: .destructive) {
                        withAnimation {
                            state.removeCategory(category)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .padding(16)
        .background(category.kind.tint.opacity(colorScheme == .dark ? 0.2 : 0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(category.kind.tint.opacity(colorScheme == .dark ? 0.4 : 0.3), lineWidth: 1)
        }
        .onAppear {
            budgetText = String(format: "%.0f", category.budget)
        }
    }
}
