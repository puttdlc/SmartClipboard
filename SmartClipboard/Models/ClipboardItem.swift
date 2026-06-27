import Foundation

enum ContentCategory: String, Codable, CaseIterable {
    case url
    case email
    case phone
    case colorHex
    case json
    case code
    case plainText

    var systemImage: String {
        switch self {
        case .url:       return "link"
        case .email:     return "envelope"
        case .phone:     return "phone"
        case .colorHex:  return "paintpalette"
        case .json:      return "curlybraces"
        case .code:      return "chevron.left.forwardslash.chevron.right"
        case .plainText: return "doc.text"
        }
    }

    var label: String {
        switch self {
        case .url:       return "URL"
        case .email:     return "Email"
        case .phone:     return "Phone"
        case .colorHex:  return "Color"
        case .json:      return "JSON"
        case .code:      return "Code"
        case .plainText: return "Text"
        }
    }
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let category: ContentCategory
    let timestamp: Date

    init(content: String, category: ContentCategory) {
        self.id = UUID()
        self.content = content
        self.category = category
        self.timestamp = Date()
    }

    var preview: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Number of non-empty lines beyond the first 2.
    var extraLineCount: Int {
        let lines = content
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return max(0, lines.count - 2)
    }

    var relativeTime: String {
        Self.relativeDateFormatter.localizedString(for: timestamp, relativeTo: Date())
    }

    private static let relativeDateFormatter = RelativeDateTimeFormatter()
}
