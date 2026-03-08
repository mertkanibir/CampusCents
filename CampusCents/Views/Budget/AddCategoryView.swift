import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState

    @State private var name = ""
    @State private var budgetText = ""
    @State private var isIncome = false
    @State private var selectedColor: Color = Colors.periwinkle

    let presetColors: [Color] = [
        Colors.mint, Colors.periwinkle, Colors.rose,
        Colors.sky, Colors.lavender, Colors.sun,
        Colors.blueMint, Colors.pistachio, Colors.peach
    ]

    private func saveAndDismiss() {
        let value = Double(budgetText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, value > 0 else { return }
        state.addCustomCategory(
            name: trimmedName,
            budget: value,
            isIncome: isIncome,
            color: selectedColor
        )
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Category Name", text: $name)
                    
                    TextField("Budget Amount", text: $budgetText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Type") {
                    Picker("Category Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.headline.weight(.bold))
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Custom Tab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveAndDismiss) {
                        Text("Save")
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || budgetText.isEmpty)
                }
            }
        }
    }
}
