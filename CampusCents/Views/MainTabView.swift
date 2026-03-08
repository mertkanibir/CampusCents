import SwiftUI

struct MainTabView: View {
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
    }
}
