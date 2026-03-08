import SwiftUI

struct BreakdownView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddCategory = false

    var incomeCategories: [BudgetCategory] {
        state.categories.filter { $0.kind.isIncome }
    }

    var expenseCategories: [BudgetCategory] {
        state.categories.filter { !$0.kind.isIncome }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Income")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(colorScheme == .dark ? .white : .primary)
                            .padding(.horizontal)
                        
                        ForEach(incomeCategories) { category in
                            CategoryRow(category: category)
                                .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expenditures")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(colorScheme == .dark ? .white : .primary)
                            .padding(.horizontal)
                        
                        ForEach(expenseCategories) { category in
                            CategoryRow(category: category)
                                .padding(.horizontal)
                        }
                    }
                    
                }
                .padding(.vertical)
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    showingAddCategory = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Add Custom Tab")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.periwinkle, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Colors.periwinkle.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Budget")
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
}
