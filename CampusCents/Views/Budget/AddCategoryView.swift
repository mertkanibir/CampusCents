import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState

    @State private var name = ""
    @State private var desc = ""
    @State private var budgetText = ""
    @State private var isIncome = false
    @State private var selectedColor: Color = Colors.periwinkle
    @State private var selectedIcon = "bag.fill"

    let presetColors: [Color] = [
        Colors.mint, Colors.periwinkle, Colors.rose,
        Colors.sky, Colors.lavender, Colors.sun,
        Colors.blueMint, Colors.pistachio, Colors.peach
    ]
    
    let presetIcons = ["bag.fill", "cart.fill", "car.fill", "house.fill", "book.fill", "gamecontroller.fill", "heart.fill", "star.fill", "airplane", "fork.knife", "desktopcomputer", "pills.fill", "cross.case.fill", "graduationcap.fill", "dollarsign.circle.fill", "creditcard.fill", "gift.fill", "music.note"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Category Name", text: $name)
                    TextField("Description (Optional)", text: $desc)
                    
                    TextField("Budget Amount / Month", text: $budgetText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Type") {
                    Picker("Category Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(presetIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
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
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let value = Double(budgetText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, value > 0 else { return }
                        state.addCustomCategory(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            desc: desc.trimmingCharacters(in: .whitespacesAndNewlines),
                            budget: value,
                            isIncome: isIncome,
                            icon: selectedIcon,
                            color: selectedColor
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || budgetText.isEmpty)
                }
            }
        }
    }
}
