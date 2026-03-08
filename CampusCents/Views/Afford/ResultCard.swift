import SwiftUI

struct ResultCard: View {
    let result: AffordabilityResult

    var body: some View {
        let ui: (String, Color, String, String) = {
            switch result {
            case .safe(let message): return ("Safe", Colors.mint, "checkmark.seal.fill", message)
            case .mostlySafe(let message): return ("Mostly Safe", Colors.sky, "hand.thumbsup.fill", message)
            case .risky(let message): return ("Risky", Colors.sun, "exclamationmark.triangle.fill", message)
            case .no(let message): return ("Not Recommended", Colors.peach, "xmark.octagon.fill", message)
            }
        }()

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: ui.2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(ui.1, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(ui.0)
                    .font(.headline)
            }
            Text(ui.3)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
