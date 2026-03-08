import SwiftUI

struct BreakdownView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(state.categories) { category in
                    CategoryRow(category: category)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Budget")
        }
    }
}
