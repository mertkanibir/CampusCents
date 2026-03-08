import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var state = AppState()

    var body: some View {
        ZStack {
            Colors.appGradient(for: colorScheme).ignoresSafeArea()

            if state.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(state)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView()
                    .environmentObject(state)
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.3), value: state.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
}
