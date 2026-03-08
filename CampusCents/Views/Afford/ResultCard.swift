import SwiftUI

struct ResultCard: View {
    let result: AffordabilityResult

    var body: some View {
        let ui: (title: String, accent: Color, icon: String, message: String, meter: Double) = {
            switch result {
            case .safe(let message): return ("Safe", Colors.mint, "checkmark.seal.fill", message, 0.9)
            case .mostlySafe(let message): return ("Mostly Safe", Colors.sky, "hand.thumbsup.fill", message, 0.68)
            case .risky(let message): return ("Risky", Colors.sun, "exclamationmark.triangle.fill", message, 0.42)
            case .no(let message): return ("Not Recommended", Colors.peach, "xmark.octagon.fill", message, 0.2)
            }
        }()

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(ui.accent.opacity(0.25))
                        .frame(width: 44, height: 44)
                    Image(systemName: ui.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ui.accent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Affordability Verdict")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(ui.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text("\(Int(ui.meter * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ui.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ui.accent.opacity(0.15))
                    )
            }

            Text(ui.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Budget Comfort")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(ui.meter > 0.6 ? "Strong" : (ui.meter > 0.35 ? "Moderate" : "Low"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ui.accent)
                }
                GeometryReader { proxy in
                    let width = max(0, proxy.size.width * ui.meter)
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [ui.accent.opacity(0.9), ui.accent.opacity(0.55)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: width)
                    }
                }
                .frame(height: 9)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ui.accent.opacity(0.14), Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(ui.accent.opacity(0.35), lineWidth: 1)
            }
        )
        .shadow(color: ui.accent.opacity(0.2), radius: 14, x: 0, y: 10)
    }
}
