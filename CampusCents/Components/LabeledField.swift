import SwiftUI

struct LabeledField: View {
    let title: String
    @Binding var value: String
    var hint: String? = nil
    var placeholder: String? = nil
    var labelColor: Color = .secondary
    var textColor: Color = .primary
    var backgroundColor: Color? = nil
    var cornerRadius: CGFloat = 8
    var strokeColor: Color? = nil

    init(_ title: String, value: Binding<String>, hint: String? = nil, placeholder: String? = nil, labelColor: Color = .secondary, textColor: Color = .primary, backgroundColor: Color? = nil, cornerRadius: CGFloat = 8, strokeColor: Color? = nil) {
        self.title = title
        self._value = value
        self.hint = hint
        self.placeholder = placeholder
        self.labelColor = labelColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
    }

    private var fieldPlaceholder: String { placeholder ?? title }

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
                TextField(fieldPlaceholder, text: $value)
                    .textFieldStyle(.plain)
                    .foregroundStyle(textColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(backgroundColor!))
                    .overlay {
                        if let strokeColor {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(strokeColor, lineWidth: 1)
                        }
                    }
            } else {
                TextField(fieldPlaceholder, text: $value)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(textColor)
            }
        }
    }
}
