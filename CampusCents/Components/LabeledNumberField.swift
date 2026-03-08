import SwiftUI

struct LabeledNumberField: View {
    let title: String
    @Binding var value: Double
    @State private var text: String = ""

    init(_ title: String, value: Binding<Double>) {
        self.title = title
        self._value = value
        self._text = State(initialValue: String(format: "%.0f", value.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .onChange(of: text) { _, newValue in
                    let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                    if let parsed = Double(cleaned) {
                        value = parsed
                    }
                }
        }
    }
}
