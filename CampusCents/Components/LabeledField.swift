import SwiftUI

struct LabeledField: View {
    let title: String
    @Binding var value: String
    var labelColor: Color = .secondary

    init(_ title: String, value: Binding<String>, labelColor: Color = .secondary) {
        self.title = title
        self._value = value
        self.labelColor = labelColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(labelColor)
            TextField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }
    }
}
