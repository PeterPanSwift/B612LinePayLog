import SwiftUI
import SwiftData

/// 手動新增一筆消費（不經過 LINE Pay 通知）。
struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var merchant = ""
    @State private var amount: Decimal?
    @State private var receivedAt = Date.now
    @State private var itemName = ""

    private var canSave: Bool {
        !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (amount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("消費資訊") {
                    TextField("商家", text: $merchant)
                    TextField("金額", value: $amount, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    DatePicker("時間", selection: $receivedAt)
                }
                Section("品項") {
                    TextField("品項名稱（選填）", text: $itemName)
                }
            }
            .navigationTitle("新增消費")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        guard let amount, canSave else { return }
        let expense = Expense(
            merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            receivedAt: receivedAt,
            rawText: "",
            itemName: itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: Expense.self, inMemory: true)
}
