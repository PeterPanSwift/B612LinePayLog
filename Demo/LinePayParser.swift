import Foundation

/// 解析 LINE 錢包的「LINE Pay 付款完成」通知文字。
///
/// 範例：
/// `LINE Pay 付款 NT$ 18 付款完成。 商店名稱: 統一超商－天鑫： 回饋: 中信 LINE Pay卡一般消費回饋 ...`
nonisolated enum LinePayParser {
    struct Payment: Equatable {
        var merchant: String
        var amount: Decimal
    }

    static let unknownMerchant = "未知商家"

    /// 不是付款通知（例如退款、行銷訊息）或找不到金額時回傳 nil。
    static func parse(_ text: String) -> Payment? {
        guard text.contains("付款"), !text.contains("退款") else { return nil }
        guard let amount = parseAmount(in: text) else { return nil }
        return Payment(merchant: parseMerchant(in: text) ?? unknownMerchant, amount: amount)
    }

    private static func parseAmount(in text: String) -> Decimal? {
        guard let match = text.firstMatch(of: #/NT\$\s*([0-9][0-9,]*(?:\.[0-9]+)?)/#) else { return nil }
        return Decimal(string: String(match.1).replacingOccurrences(of: ",", with: ""), locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func parseMerchant(in text: String) -> String? {
        // 商家名稱後面通常接「： 回饋:」，以「回饋:」作為結尾；沒有回饋段落時取到文字結尾。
        let raw: Substring?
        if let match = text.firstMatch(of: #/商店名稱\s*[:：]\s*(.+?)\s*(?:[:：]\s*)?(?=回饋\s*[:：])/#) {
            raw = match.1
        } else if let match = text.firstMatch(of: #/商店名稱\s*[:：]\s*([^\n]+)/#) {
            raw = match.1
        } else {
            raw = nil
        }
        guard let raw else { return nil }
        let merchant = raw.trimmingCharacters(in: CharacterSet(charactersIn: ":：").union(.whitespacesAndNewlines))
        return merchant.isEmpty ? nil : merchant
    }
}
