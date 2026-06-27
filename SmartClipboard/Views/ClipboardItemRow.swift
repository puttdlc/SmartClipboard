import SwiftUI

struct ClipboardItemRow: View {
    @Environment(ClipboardStore.self) private var store
    @Environment(TimeTicker.self) private var ticker
    let item: ClipboardItem
    let onExpand: () -> Void
    @State private var isHovered = false
    @State private var copied = false

    var body: some View {
        // Reading ticker.tick registers this view as an observer so it re-renders each second.
        let _ = ticker.tick

        return HStack(alignment: .top, spacing: 10) {
            categoryIcon

            // Tapping the content area opens the detail view.
            Button(action: onExpand) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.preview)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 6) {
                        if item.extraLineCount > 0 {
                            Text("…\(item.extraLineCount) more lines")
                                .font(.system(size: 10))
                                .foregroundStyle(.blue)
                        }
                        Text(item.category.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(categoryColor)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        Text(item.relativeTime)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            if isHovered {
                HStack(spacing: 4) {
                    copyButton
                    deleteButton
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        )
        .onHover { isHovered = $0 }
        .contextMenu {
            Button("Copy") { copy() }
            Button("Expand") { onExpand() }
            Divider()
            Button("Delete", role: .destructive) { delete() }
        }
    }

    // MARK: - Subviews

    private var categoryIcon: some View {
        Image(systemName: item.category.systemImage)
            .font(.system(size: 11))
            .foregroundStyle(categoryColor)
            .frame(width: 22, height: 22)
            .background(categoryColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private var copyButton: some View {
        Button(action: copy) {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 11))
                .foregroundStyle(copied ? Color.green : Color.secondary)
                .frame(width: 26, height: 26)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .help("Copy")
    }

    private var deleteButton: some View {
        Button(action: delete) {
            Image(systemName: "trash")
                .font(.system(size: 11))
                .foregroundStyle(Color.red.opacity(0.8))
                .frame(width: 26, height: 26)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .help("Delete")
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch item.category {
        case .url:       return .blue
        case .email:     return .purple
        case .phone:     return .green
        case .colorHex:  return .orange
        case .json:      return .yellow
        case .code:      return .cyan
        case .plainText: return .gray
        }
    }

    private func copy() {
        store.copyToClipboard(item)
        copied = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copied = false
        }
    }

    private func delete() {
        if let idx = store.items.firstIndex(where: { $0.id == item.id }) {
            store.remove(at: IndexSet(integer: idx))
        }
    }
}
