import Foundation

struct ContentDetector {
    private static let urlPattern     = try! NSRegularExpression(pattern: #"^https?://\S+$"#, options: .caseInsensitive)
    private static let emailPattern   = try! NSRegularExpression(pattern: #"^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$"#, options: .caseInsensitive)
    private static let phonePattern   = try! NSRegularExpression(pattern: #"^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$"#)
    private static let hexPattern     = try! NSRegularExpression(pattern: #"^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$"#)
    private static let keywordPattern = try! NSRegularExpression(pattern: #"(func |class |import |var |let |const |def |fn |public |private |return )"#)
    private static let operatorPattern = try! NSRegularExpression(pattern: #"(\{|\}|=>|==|!=|&&|\|\|)"#)

    static func detect(_ text: String) -> ContentCategory {
        let s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let r = NSRange(s.startIndex..., in: s)

        if urlPattern.firstMatch(in: s, range: r) != nil   { return .url }
        if emailPattern.firstMatch(in: s, range: r) != nil { return .email }
        if phonePattern.firstMatch(in: s, range: r) != nil &&
           s.contains(where: { !$0.isNumber })             { return .phone }
        if hexPattern.firstMatch(in: s, range: r) != nil   { return .colorHex }
        if isJSON(s)                                        { return .json }
        if keywordPattern.numberOfMatches(in: s, range: r) >= 1 &&
           operatorPattern.numberOfMatches(in: s, range: r) >= 1 { return .code }
        return .plainText
    }

    private static func isJSON(_ s: String) -> Bool {
        guard s.utf8.count < 512_000 else { return false }
        guard (s.hasPrefix("{") && s.hasSuffix("}")) ||
              (s.hasPrefix("[") && s.hasSuffix("]")) else { return false }
        return (try? JSONSerialization.jsonObject(with: Data(s.utf8))) != nil
    }
}
