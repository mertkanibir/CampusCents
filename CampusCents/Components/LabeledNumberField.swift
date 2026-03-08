import SwiftUI

struct LabeledNumberField: View {
    let title: String
    @Binding var value: Double
    var labelColor: Color = .secondary
    var textColor: Color = .primary
    var backgroundColor: Color? = nil
    @State private var text: String = ""

    init(_ title: String, value: Binding<Double>, labelColor: Color = .secondary, textColor: Color = .primary, backgroundColor: Color? = nil) {
        self.title = title
        self._value = value
        self.labelColor = labelColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self._text = State(initialValue: String(format: "%.0f", value.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(labelColor)
            if backgroundColor != nil {
                TextField(title, text: $text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .foregroundStyle(textColor)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(backgroundColor!))
                    .onChange(of: text) { _, newValue in
                        let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                        if let parsed = Double(cleaned) {
                            value = parsed
                        }
                    }
            } else {
                TextField(title, text: $text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(textColor)
                    .onChange(of: text) { _, newValue in
                        let cleaned = newValue.replacingOccurrences(of: ",", with: ".")
                        if let parsed = Double(cleaned) {
                            value = parsed
                        }
                    }
            }
        }
    }
}
