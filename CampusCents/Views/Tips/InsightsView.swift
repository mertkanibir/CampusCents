import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var service = AIService()
    @State private var aiResponse: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false
    @State private var selectedFilter: InsightFilter = .all
    @State private var expandedInsightIDs: Set<String> = []

    private enum InsightFilter: String, CaseIterable {
        case all = "All"
        case watch = "Watch"
        case positive = "Wins"

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2.fill"
            case .watch: return "exclamationmark.triangle.fill"
            case .positive: return "checkmark.seal.fill"
            }
        }
    }

    private var key: String {
        "\(state.profile.id.uuidString)-\(state.spent)-\(state.total)-\(state.transactions.count)"
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.84) : Color.primary.opacity(0.68)
    }

    private var tertiaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.58)
    }

    private var quietText: Color {
        colorScheme == .dark ? Color.white.opacity(0.64) : Color.primary.opacity(0.5)
    }

    private var filteredInsights: [Insight] {
        switch selectedFilter {
        case .all:
            return state.insights
        case .watch:
            return state.insights.filter { $0.tone == .watch }
        case .positive:
            return state.insights.filter { $0.tone == .positive }
        }
    }

    private var watchCount: Int {
        state.insights.filter { $0.tone == .watch }.count
    }

    private var positiveCount: Int {
        state.insights.filter { $0.tone == .positive }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard
                    aiAnalysisCard
                    insightFeedCard
                }
                .padding()
            }
            .navigationTitle("Insights Lab")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: key) {
                await refreshAI()
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.15, green: 0.18, blue: 0.45),
                                Color(red: 0.08, green: 0.19, blue: 0.29),
                                Color(red: 0.05, green: 0.08, blue: 0.16)
                            ]
                            : [
                                Colors.periwinkle.opacity(0.22),
                                Colors.blueMint.opacity(0.14),
                                Color.white.opacity(0.96)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Colors.periwinkle.opacity(colorScheme == .dark ? 0.95 : 0.72),
                                    Colors.blueMint.opacity(colorScheme == .dark ? 0.72 : 0.42)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }

            Circle()
                .fill(Colors.blueMint.opacity(colorScheme == .dark ? 0.22 : 0.14))
                .frame(width: 180, height: 180)
                .blur(radius: 22)
                .offset(x: 180, y: -20)

            Circle()
                .fill(Colors.periwinkle.opacity(colorScheme == .dark ? 0.18 : 0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: -30, y: 110)

            VStack(alignment: .leading, spacing: 16) {
                Label("AI Spending Intelligence", systemImage: "sparkles.rectangle.stack")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color.white.opacity(0.12) : Colors.periwinkle.opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : Colors.periwinkle.opacity(0.16), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Understand where your budget is under pressure.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("This page combines AI analysis with category warnings so you can quickly spot what needs attention and what is already going well.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    heroMetric(title: "Health Score", value: "\(state.healthScore)", detail: "Overall budget health", tint: Colors.mint)
                    heroMetric(title: "Watch Items", value: "\(watchCount)", detail: "Need attention", tint: watchCount > 0 ? Colors.sun : Colors.blueMint)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: Colors.periwinkle.opacity(colorScheme == .dark ? 0.2 : 0.14), radius: 20, y: 10)
    }

    private var aiAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Overview")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(primaryText)
                    Text("A summarized read on your spending pressure and flexibility.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
                Spacer()
                Button {
                    Task { await refreshAI() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Colors.periwinkle.opacity(colorScheme == .dark ? 0.3 : 0.12), in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(colorScheme == .dark ? primaryText : Colors.periwinkle)
            }

            HStack(spacing: 12) {
                summaryPill(title: "Flexibility", value: aiResponse?.flexibility.displayName ?? "Loading", tint: flexibilityTint)
                summaryPill(title: "Positive Signals", value: "\(positiveCount)", tint: Colors.mint)
            }

            if isLoading && aiResponse == nil {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Generating AI overview...")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
            } else if let aiResponse {
                Text(aiResponse.summary)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(secondaryText)

                if !aiResponse.points.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key pressure points")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tertiaryText)
                        ForEach(Array(aiResponse.points.prefix(3).enumerated()), id: \.offset) { index, point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 7))
                                    .foregroundStyle(pointTint(for: index))
                                    .padding(.top, 6)
                                Text(point)
                                    .font(.caption)
                                    .foregroundStyle(secondaryText)
                            }
                        }
                    }
                }

                if !aiResponse.suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Suggested next moves")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tertiaryText)
                        ForEach(Array(aiResponse.suggestions.prefix(2).enumerated()), id: \.offset) { _, suggestion in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "sparkle")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Colors.periwinkle)
                                    .padding(.top, 2)
                                Text(suggestion)
                                    .font(.caption)
                                    .foregroundStyle(secondaryText)
                            }
                        }
                    }
                }
            } else {
                Text("AI analysis will appear here once your current budget snapshot is processed.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }

            Text(availability.statusLabel)
                .font(.caption2)
                .foregroundStyle(quietText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 16, y: 8)
    }

    private var insightFeedCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Insight Feed")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(primaryText)
                Text("Filter between warnings and wins to focus on the most useful signals.")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)
            }

            HStack(spacing: 10) {
                ForEach(InsightFilter.allCases, id: \.self) { filter in
                    filterChip(for: filter)
                }
            }

            if filteredInsights.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No insights in this filter right now.")
                        .font(.headline)
                        .foregroundStyle(primaryText)
                    Text("Try another filter or add more transactions so the app has more signals to analyze.")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ForEach(filteredInsights) { item in
                    InsightRow(
                        insight: item,
                        isExpanded: expandedInsightIDs.contains(item.id),
                        onTap: { toggleExpansion(for: item.id) }
                    )
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.cardFill(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Colors.cardStroke(for: colorScheme), lineWidth: 1)
        }
    }

    private var flexibilityTint: Color {
        switch aiResponse?.flexibility {
        case .comfortable:
            return Colors.mint
        case .moderate:
            return Colors.sky
        case .tight:
            return Colors.sun
        case nil:
            return Colors.periwinkle
        }
    }

    private func heroMetric(title: String, value: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.76) : Color.primary.opacity(0.6))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(primaryText)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(quietText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(colorScheme == .dark ? 0.26 : 0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .dark ? 0.56 : 0.3), lineWidth: 1)
        }
    }

    private func summaryPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tertiaryText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(colorScheme == .dark ? primaryText : tint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(colorScheme == .dark ? 0.24 : 0.09), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .dark ? 0.46 : 0.2), lineWidth: 1)
        }
    }

    private func filterChip(for filter: InsightFilter) -> some View {
        let isSelected = selectedFilter == filter
        let tint: Color = switch filter {
        case .all: Colors.periwinkle
        case .watch: Colors.sun
        case .positive: Colors.mint
        }

        return Button {
            selectedFilter = filter
        } label: {
            Label(filter.rawValue, systemImage: filter.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? primaryText : tertiaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? tint.opacity(colorScheme == .dark ? 0.28 : 0.14)
                        : Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(isSelected ? tint.opacity(colorScheme == .dark ? 0.48 : 0.22) : Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func pointTint(for index: Int) -> Color {
        [Colors.periwinkle, Colors.blueMint, Colors.mint][index % 3]
    }

    private func toggleExpansion(for id: String) {
        if expandedInsightIDs.contains(id) {
            expandedInsightIDs.remove(id)
        } else {
            expandedInsightIDs.insert(id)
        }
    }

    @MainActor
    private func refreshAI() async {
        isLoading = true
        availability = await service.availability()
        aiResponse = await service.financialSnapshot(for: state.budgetInput)
        isLoading = false
    }
}
