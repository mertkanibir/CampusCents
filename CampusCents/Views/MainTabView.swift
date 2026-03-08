import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            BreakdownView()
                .tabItem { Label("Budget", systemImage: "chart.pie.fill") }

            AffordabilityView()
                .tabItem { Label("Afford", systemImage: "checkmark.seal.fill") }

            InsightsView()
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }

            AddTabView()
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }
        }
        .tint(Colors.periwinkle)
        .toolbarBackground(colorScheme == .dark ? Color.black.opacity(0.32) : Color.white.opacity(0.92), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
