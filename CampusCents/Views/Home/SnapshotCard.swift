import SwiftUI

struct SnapshotCard: View {
    @EnvironmentObject var state: AppState
    @State private var service = AIService()
    @State private var response: AIResponse?
    @State private var availability: AIStatus = .frameworkUnavailable
    @State private var isLoading = false

    private var key: String {
        "\(state.profile.id.uuidString)-\(state.total)-\(state.spent)-\(state.transactions.count)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("AI Snapshot", systemImage: "sparkles.rectangle.stack")
                    .font(.headline)
                Spacer()
                Text(availability.isAvailable ? "On-device" : "Fallback")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(availability.isAvailable ? Colors.mint : Colors.sun)
            }

            if isLoading && response == nil {
                ProgressView()
            } else if let response {
                Text(response.summary)
                    .font(.subheadline)
                ForEach(response.points.prefix(3), id: \.self) { point in
                    Label(point, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Generating budget snapshot…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(availability.statusLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .task(id: key) {
            await refresh()
        }
    }

    @MainActor
    private func refresh() async {
        isLoading = true
        availability = await service.availability()
        response = await service.financialSnapshot(for: state.budgetInput)
        isLoading = false
    }
}
