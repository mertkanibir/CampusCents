import SwiftUI

struct CategoryRow: View {
    @EnvironmentObject var state: AppState
    let category: BudgetCategory
    @State private var budgetText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(category.name, systemImage: category.kind.icon)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(category.spent.currency) / \(category.budget.currency)")
                    .font(.caption)
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
                .tint(Colors.periwinkle)
            }
        }
        .padding(.vertical, 6)
        .onAppear {
            budgetText = String(format: "%.0f", category.budget)
        }
    }
}
