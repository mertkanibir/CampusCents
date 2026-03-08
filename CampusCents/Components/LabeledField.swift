import SwiftUI

struct LabeledField: View {
    let title: String
    @Binding var value: String
    var labelColor: Color = .secondary
    var textColor: Color = .primary
    var backgroundColor: Color? = nil

    init(_ title: String, value: Binding<String>, labelColor: Color = .secondary, textColor: Color = .primary, backgroundColor: Color? = nil) {
        self.title = title
        self._value = value
        self.labelColor = labelColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(labelColor)
            if backgroundColor != nil {
                TextField(title, text: $value)
                    .textFieldStyle(.plain)
                    .foregroundStyle(textColor)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(backgroundColor!))
            } else {
                TextField(title, text: $value)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(textColor)
            }
        }
    }
}
