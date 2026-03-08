import SwiftUI

struct LabeledField: View {
    let title: String
    @Binding var value: String

    init(_ title: String, value: Binding<String>) {
        self.title = title
        self._value = value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            TextField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }
    }
}
