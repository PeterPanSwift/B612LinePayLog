import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.receivedAt, order: .reverse) private var expenses: [Expense]
    @State private var isAdding = false

    private var days: [(day: Date, items: [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.receivedAt) }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if expenses.isEmpty {
                    ContentUnavailableView {
                        VStack(spacing: 12) {
                            Image("Fox")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .accessibilityHidden(true)
                            Text("尚無消費紀錄")
                        }
                    } description: {
                        Text("收到 LINE Pay 付款通知後，捷徑會自動在這裡新增紀錄，也可以按右上角的「＋」手動新增。")
                    }
                } else {
                    list
                }
            }
            .navigationTitle("消費紀錄")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("新增消費", systemImage: "plus") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) { AddExpenseView() }
        }
    }

    private var list: some View {
        List {
            Image("Fox")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            ForEach(days, id: \.day) { group in
                Section {
                    ForEach(group.items) { expense in
                        NavigationLink(value: expense) {
                            ExpenseRow(expense: expense)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { modelContext.delete(group.items[index]) }
                    }
                } header: {
                    HStack {
                        Text(group.day, format: .dateTime.year().month().day().weekday())
                        Spacer()
                        Text(total(of: group.items))
                    }
                }
            }
        }
        .navigationDestination(for: Expense.self) { ExpenseDetailView(expense: $0) }
    }

    private func total(of items: [Expense]) -> String {
        "NT$ " + items.reduce(Decimal.zero) { $0 + $1.amount }.formatted(.number.precision(.fractionLength(0...2)))
    }

}

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                if expense.itemName.isEmpty {
                    Text("尚未輸入品項").foregroundStyle(.secondary)
                } else {
                    Text(expense.itemName)
                }
                Text(expense.merchant)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(expense.receivedAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Text(expense.amountText)
                .monospacedDigit()
        }
    }
}

#Preview("無紀錄") {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}

#Preview("有紀錄") {
    let container = try! ModelContainer(for: Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let samples = [
        Expense(merchant: "統一超商－天鑫", amount: 18, receivedAt: .now, rawText: "LINE Pay 付款 NT$ 18 付款完成。"),
        Expense(merchant: "全聯福利中心", amount: 1250.5, receivedAt: .now.addingTimeInterval(-3600), rawText: "", itemName: "週末採買"),
        Expense(merchant: "星巴克", amount: 135, receivedAt: .now.addingTimeInterval(-86400 * 1), rawText: "", itemName: "拿鐵"),
    ]
    samples.forEach { container.mainContext.insert($0) }
    return ContentView().modelContainer(container)
}
