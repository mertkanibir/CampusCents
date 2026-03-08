import SwiftUI

struct LabeledNumberField: View {
    let title: String
    @Binding var value: Double
    var hint: String? = nil
    var isCurrency: Bool = false
    var placeholder: String = "0"
    var labelColor: Color = .secondary
    var textColor: Color = .primary
    var backgroundColor: Color? = nil
    @State private var text: String = ""

    init(_ title: String, value: Binding<Double>, hint: String? = nil, isCurrency: Bool = false, placeholder: String = "0", labelColor: Color = .secondary, textColor: Color = .primary, backgroundColor: Color? = nil) {
        self.title = title
        self._value = value
        self.hint = hint
        self.isCurrency = isCurrency
        self.placeholder = placeholder
        self.labelColor = labelColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        let v = value.wrappedValue
        self._text = State(initialValue: v == 0 ? "" : String(format: "%.0f", v))
    }

    private var effectiveTextColor: Color { value == 0 ? labelColor : textColor }

    private static func numericOnly(_ s: String) -> String {
        var result = ""
        var hasDecimal = false
        for c in s {
            if c.isNumber { result.append(c) }
            else if c == "." && !hasDecimal { result.append(c); hasDecimal = true }
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !title.isEmpty {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(labelColor)
            }
            if let hint {
                Text(hint)
                    .font(.caption2)
                    .foregroundStyle(labelColor.opacity(0.8))
            }
            if backgroundColor != nil {
                HStack(spacing: 6) {
                    if isCurrency {
                        Text("$")
                            .font(.body)
                            .foregroundStyle(effectiveTextColor.opacity(0.7))
                    }
                    TextField(placeholder, text: $text)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .foregroundStyle(effectiveTextColor)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(backgroundColor!))
                .onChange(of: text) { _, newValue in
                    let cleaned = Self.numericOnly(newValue)
                    if cleaned != newValue { text = cleaned }
                    value = Double(cleaned) ?? 0
                }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(effectiveTextColor)
                    .onChange(of: text) { _, newValue in
                        let cleaned = Self.numericOnly(newValue)
                        if cleaned != newValue { text = cleaned }
                        value = Double(cleaned) ?? 0
                    }
            }
        }
    }
}
