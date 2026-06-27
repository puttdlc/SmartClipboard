import SwiftUI

struct DetailView: View {
    @Environment(ClipboardStore.self) private var store
    let item: ClipboardItem
    let onBack: () -> Void
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            metadata
            Divider()
            fullContent
            Divider()
            copyAction
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 13))
                }
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: item.category.systemImage)
                    .font(.system(size: 10))
                Text(item.category.label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(categoryColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(categoryColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var metadata: some View {
        HStack {
            Text(item.timestamp, style: .date)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Text("·")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
            Text(item.timestamp, style: .time)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(item.content.count) chars")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
    }

    private var fullContent: some View {
        ScrollView {
            Text(item.content)
                .font(.system(
                    size: 12,
                    design: (item.category == .code || item.category == .json) ? .monospaced : .default
                ))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .textSelection(.enabled)
        }
    }

    private var copyAction: some View {
        Button(action: copy) {
            HStack(spacing: 6) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12))
                Text(copied ? "Copied!" : "Copy to Clipboard")
                    .font(.system(size: 13, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(copied ? Color.green.opacity(0.12) : Color.accentColor.opacity(0.1))
            .foregroundStyle(copied ? Color.green : Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.2), value: copied)
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
}
