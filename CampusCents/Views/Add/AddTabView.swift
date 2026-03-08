import SwiftUI

struct AddTabView: View {
    @EnvironmentObject var state: AppState
    @State private var showingAddSheet = false
    @State private var addSheetPrefill: TransactionTemplate?
    @State private var showingRecurringSheet = false

    private var recentTransactions: [Transaction] {
        state.transactions.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                addButtonCard

                templatesSection
                recurringSection
                recentSection
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(prefill: addSheetPrefill)
                .environmentObject(state)
                .onDisappear { addSheetPrefill = nil }
        }
        .sheet(isPresented: $showingRecurringSheet) {
            AddRecurringView()
                .environmentObject(state)
        }
    }

    private var addButtonCard: some View {
        Button {
            addSheetPrefill = nil
            showingAddSheet = true
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Colors.sky.opacity(0.3), lineWidth: 1)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Colors.periwinkle)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.08), radius: 14, y: 6)

                Text("Add transaction")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
        .buttonStyle(.plain)
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Templates")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(state.templates) { template in
                        Button {
                            addSheetPrefill = template
                            showingAddSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: template.category.icon)
                                    .font(.subheadline)
                                    .foregroundStyle(template.category.tint)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                    Text(template.amount.currency)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Colors.sky.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recurring")
                    .font(.headline)
                Spacer()
                Button {
                    showingRecurringSheet = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Colors.periwinkle)
                }
            }
            if state.recurring.isEmpty {
                Text("No recurring expenses. Tap Add to create one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(state.recurring) { rec in
                        recurringRow(rec)
                    }
                }
            }
        }
    }

    private func recurringRow(_ rec: RecurringTransaction) -> some View {
        HStack(spacing: 10) {
            Image(systemName: rec.category.icon)
                .foregroundStyle(.white)
                .padding(8)
                .background(rec.category.tint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(rec.title)
                    .font(.subheadline.weight(.medium))
                Text("\(rec.frequency.displayName) · Next: \(rec.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(rec.amount.currency)
                    .font(.subheadline.bold())
                HStack(spacing: 8) {
                    Button("Add now") {
                        state.addOccurrence(for: rec)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Colors.periwinkle)
                    Button {
                        state.removeRecurring(rec)
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Colors.sky.opacity(0.2), lineWidth: 1)
        )
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent")
                .font(.headline)
            if recentTransactions.isEmpty {
                Text("No transactions yet. Add one above.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(recentTransactions.prefix(6)) { transaction in
                        HStack(spacing: 10) {
                            Image(systemName: transaction.category.icon)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(transaction.category.tint, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(transaction.title)
                                    .font(.subheadline)
                                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(transaction.amount.currency)
                                .font(.subheadline.bold())
                        }
                        .padding(12)
                        if transaction.id != recentTransactions.prefix(6).last?.id {
                            Divider()
                                .padding(.leading, 54)
                        }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Colors.sky.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}
