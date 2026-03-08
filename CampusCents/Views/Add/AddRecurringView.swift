import SwiftUI

struct AddRecurringView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState

    @State private var title = ""
    @State private var amountText = ""
    @State private var category: BudgetCategory.Kind = .groceries
    @State private var frequency: RecurringTransaction.Frequency = .monthly
    @State private var startDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Recurring expense") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $category) {
                        ForEach(state.categories.map(\.kind), id: \.self) { kind in
                            if kind != .aid {
                                Label(kind.displayName, systemImage: kind.icon)
                                    .tag(kind)
                            }
                        }
                    }
                    Picker("Frequency", selection: $frequency) {
                        ForEach(RecurringTransaction.Frequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Recurring")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let value = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, value > 0 else { return }
                        let recurring = RecurringTransaction(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: value,
                            category: category,
                            frequency: frequency,
                            startDate: startDate,
                            nextDueDate: startDate
                        )
                        state.addRecurring(recurring)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
