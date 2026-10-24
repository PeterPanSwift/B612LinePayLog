import Foundation
import SwiftData

/// App 與 App Intent 共用同一個 ModelContainer，捷徑在背景寫入的資料，App 的 @Query 會即時反映。
enum Persistence {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Expense.self)
        } catch {
            fatalError("無法建立 ModelContainer：\(error)")
        }
    }()
}

enum ExpenseRecorder {
    enum Outcome {
        case recorded(Expense)
        case duplicate
        case notAPayment
    }

    /// 解析通知文字並寫入資料庫。同一則通知（文字與時間皆相同）重複傳入時不會重複記錄，
    /// 因為 perform() 可能被系統重新執行。
    static func record(text: String, receivedAt: Date, in context: ModelContext) throws -> Outcome {
        guard let payment = LinePayParser.parse(text) else { return .notAPayment }

        var existing = FetchDescriptor<Expense>(
            predicate: #Predicate { $0.rawText == text && $0.receivedAt == receivedAt }
        )
        existing.fetchLimit = 1
        if try context.fetchCount(existing) > 0 { return .duplicate }

        let expense = Expense(merchant: payment.merchant, amount: payment.amount, receivedAt: receivedAt, rawText: text)
        context.insert(expense)
        try context.save()
        return .recorded(expense)
    }
}
