import SwiftUI

struct InsightRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let insight: Insight
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: insight.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(insight.tint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(insight.title)
                                .font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                            Spacer()
                            toneBadge
                        }

                        Text(insight.detail)
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : .secondary)
                            .lineLimit(isExpanded ? nil : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.56) : Color.primary.opacity(0.4))
                        .padding(.top, 4)
                }

                if isExpanded {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(insight.tint)
                            .padding(.top, 2)
                        Text(expandedHint)
                            .font(.caption)
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .buttonStyle(.plain)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(insight.tint.opacity(colorScheme == .dark ? 0.28 : 0.14), lineWidth: 1)
        }
    }

    private var toneBadge: some View {
        Text(toneLabel)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(colorScheme == .dark ? .white : insight.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(insight.tint.opacity(colorScheme == .dark ? 0.24 : 0.10), in: Capsule())
    }

    private var toneLabel: String {
        switch insight.tone {
        case .watch: return "Watch"
        case .positive: return "Positive"
        case .neutral: return "Info"
        }
    }

    private var expandedHint: String {
        switch insight.tone {
        case .watch:
            return "This is worth checking soon because it may reduce your flexibility or signal budget pressure."
        case .positive:
            return "This is a healthy signal. Keeping patterns like this steady should support better budget stability."
        case .neutral:
            return "This is a general context signal to help explain the bigger budget picture."
        }
    }
}
