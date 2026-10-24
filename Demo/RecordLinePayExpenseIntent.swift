import AppIntents
import SwiftData

/// 由「捷徑」個人自動化呼叫：傳入 LINE 錢包通知文字與收到通知的時間。
struct RecordLinePayExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "記錄 LINE Pay 消費"
    static let description = IntentDescription("從 LINE 錢包的付款通知文字，記錄消費的商家、金額與時間。")
    static var supportedModes: IntentModes { .background }

    @Parameter(title: "通知內容")
    var notificationText: String

    @Parameter(title: "收到時間")
    var receivedAt: Date

    static var parameterSummary: some ParameterSummary {
        Summary("記錄 \(\.$notificationText)，收到時間 \(\.$receivedAt)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Persistence.container.mainContext
        switch try ExpenseRecorder.record(text: notificationText, receivedAt: receivedAt, in: context) {
        case .recorded(let expense):
            return .result(dialog: "已記錄 \(expense.merchant) \(expense.amountText)")
        case .duplicate:
            return .result(dialog: "這則通知已記錄過")
        case .notAPayment:
            return .result(dialog: "不是付款通知，已略過")
        }
    }
}
