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

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(Colors.periwinkle)
    }
}
