import SwiftUI

struct BudgetPlanningView: View {
    @EnvironmentObject var state: AppState
    @State private var budgetStyle: BudgetInput.BudgetStyle = .monthly
    @State private var housingType: BudgetInput.HousingType = .offCampus

    var body: some View {
        List {
            Section {
                Picker("Budget style", selection: $budgetStyle) {
                    ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                Picker("Housing type", selection: $housingType) {
                    ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            } header: {
                Text("Planning")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Budget & planning")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            budgetStyle = state.profile.budgetStyle
            housingType = state.profile.housingType
        }
        .onChange(of: budgetStyle) { _, new in
            var p = state.profile
            p.budgetStyle = new
            state.profile = p
        }
        .onChange(of: housingType) { _, new in
            var p = state.profile
            p.housingType = new
            state.profile = p
        }
    }
}
