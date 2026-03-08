import SwiftUI

struct ResultCard: View {
    @Environment(\.colorScheme) private var colorScheme
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

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("AI Affordability Verdict", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ui.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ui.accent.opacity(colorScheme == .dark ? 0.2 : 0.12), in: Capsule())

                    Text(ui.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(ui.accent.opacity(colorScheme == .dark ? 0.18 : 0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: ui.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(ui.accent)
                }
            }

            HStack(spacing: 12) {
                scoreChip(title: "Budget Fit", value: "\(Int(ui.meter * 100))%", tint: ui.accent)
                scoreChip(title: "Comfort Level", value: comfortLabel(for: ui.meter), tint: ui.accent)
            }

            Text(ui.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.82 : 0.72))
                .fixedSize(horizontal: false, vertical: true)

            Text("Higher budget fit means this purchase takes a smaller share of your flexible budget.")
                .font(.caption)
                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.66 : 0.54))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Budget Comfort")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.66 : 0.56))
                    Spacer()
                    Text(comfortLabel(for: ui.meter))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ui.accent)
                }
                GeometryReader { proxy in
                    let width = max(0, proxy.size.width * ui.meter)
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.08))
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [ui.accent.opacity(0.95), ui.accent.opacity(0.55)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: width)
                            .shadow(color: ui.accent.opacity(0.4), radius: 10, y: 0)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [ui.accent.opacity(0.22), Color.white.opacity(0.04)]
                                : [ui.accent.opacity(0.16), Color.white.opacity(0.96)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(ui.accent.opacity(colorScheme == .dark ? 0.42 : 0.28), lineWidth: 1.1)
            }
        )
        .shadow(color: ui.accent.opacity(colorScheme == .dark ? 0.18 : 0.16), radius: 16, x: 0, y: 10)
    }

    private func comfortLabel(for meter: Double) -> String {
        meter > 0.6 ? "Strong" : (meter > 0.35 ? "Moderate" : "Low")
    }

    private func scoreChip(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.66 : 0.54))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(colorScheme == .dark ? 0.14 : 0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tint.opacity(colorScheme == .dark ? 0.26 : 0.16), lineWidth: 1)
        }
    }
}
