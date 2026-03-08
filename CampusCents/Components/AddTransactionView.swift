import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState

    var prefill: TransactionTemplate?

    @State private var title = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category: BudgetCategory.Kind = .groceries

    init(prefill: TransactionTemplate? = nil) {
        self.prefill = prefill
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        ForEach(state.categories.map(\.kind), id: \.self) { kind in
                            if kind != .aid {
                                Label(kind.displayName, systemImage: kind.icon)
                                    .tag(kind)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .onAppear {
                if let prefill {
                    title = prefill.title
                    amountText = prefill.amount == floor(prefill.amount) ? String(Int(prefill.amount)) : String(prefill.amount)
                    category = prefill.category
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let value = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        state.addTransaction(title: title, amount: value, date: date, category: category)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
