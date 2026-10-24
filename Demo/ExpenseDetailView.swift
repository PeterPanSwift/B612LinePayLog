import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Bindable var expense: Expense

    var body: some View {
        Form {
            Section("品項") {
                TextField("品項名稱", text: $expense.itemName)
                    .submitLabel(.done)
            }
            Section("消費資訊") {
                LabeledContent("商家", value: expense.merchant)
                LabeledContent("金額", value: expense.amountText)
                LabeledContent("時間") {
                    Text(expense.receivedAt, format: .dateTime.year().month().day().hour().minute())
                }
            }
            if !expense.rawText.isEmpty {
                Section("原始通知") {
                    Text(expense.rawText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle(expense.merchant)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
