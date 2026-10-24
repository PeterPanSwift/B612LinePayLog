import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID = UUID()
    var merchant: String = ""
    var amount: Decimal = 0
    var receivedAt: Date = Date.now
    /// 使用者事後手動輸入的品項名稱，自動記錄時為空字串。
    var itemName: String = ""
    /// 捷徑傳入的原始通知文字，保留以便日後重新解析或核對。
    var rawText: String = ""

    init(merchant: String, amount: Decimal, receivedAt: Date, rawText: String, itemName: String = "") {
        self.merchant = merchant
        self.amount = amount
        self.receivedAt = receivedAt
        self.rawText = rawText
        self.itemName = itemName
    }

    var amountText: String {
        "NT$ " + amount.formatted(.number.precision(.fractionLength(0...2)))
    }
}
