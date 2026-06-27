import SwiftUI

struct ContentView: View {
    @Environment(ClipboardStore.self) private var store
    @State private var searchText = ""
    @State private var selectedCategory: ContentCategory?
    @State private var expandedItem: ClipboardItem?
    @State private var ticker = TimeTicker()
    @State private var newCopiesCount: Int = 0
    @State private var showNewCopiesLabel: Bool = false
    @State private var lastCloseDate: Date? = nil
    @State private var dismissTask: Task<Void, Never>? = nil

    var filteredItems: [ClipboardItem] {
        store.items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.content.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil ||
                item.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let item = expandedItem {
                DetailView(item: item, onBack: { expandedItem = nil })
            } else {
                header
                Divider()
                searchBar
                Divider()
                categoryFilter
                Divider()
                itemList
            }

            Divider()
            quitFooter
        }
        .frame(width: 340, height: 520)
        .background(.regularMaterial)
        .environment(ticker)
        .onAppear {
            ticker.start()
            if let lastClose = lastCloseDate {
                let added = store.items.filter { item in
                    item.timestamp > lastClose &&
                    (searchText.isEmpty || item.content.localizedCaseInsensitiveContains(searchText)) &&
                    (selectedCategory == nil || item.category == selectedCategory)
                }.count
                if added > 0 {
                    newCopiesCount = added
                    withAnimation(.easeIn(duration: 0.4)) { showNewCopiesLabel = true }
                    dismissTask?.cancel()
                    dismissTask = Task {
                        try? await Task.sleep(for: .seconds(3))
                        guard !Task.isCancelled else { return }
                        withAnimation(.easeOut(duration: 0.8)) { showNewCopiesLabel = false }
                    }
                }
            }
        }
        .onDisappear {
            ticker.stop()
            expandedItem = nil
            lastCloseDate = Date()
            dismissTask?.cancel()
            showNewCopiesLabel = false
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Image(systemName: "doc.on.clipboard")
                .foregroundStyle(.secondary)
            Text("SmartClip")
                .fontWeight(.semibold)
            Text("\(store.items.count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.15), in: Capsule())
            if showNewCopiesLabel {
                Text("\(newCopiesCount) New \(newCopiesCount == 1 ? "Copy" : "Copies") Added")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(red: 0.45, green: 0.75, blue: 1.0))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.0, green: 0.05, blue: 0.38)))
                    .transition(.opacity)
            }
            Spacer()
            if !store.items.isEmpty {
                HoldToDeleteButton(action: store.clear)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 12))
            TextField("Search history…", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                CategoryPill(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ContentCategory.allCases, id: \.self) { cat in
                    CategoryPill(label: cat.label, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private var itemList: some View {
        Group {
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text(store.items.isEmpty ? "Nothing copied yet" : "No results")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 13))
                    Spacer()
                }
            } else {
                List(filteredItems) { item in
                    ClipboardItemRow(item: item, onExpand: { expandedItem = item })
                        .listRowInsets(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var quitFooter: some View {
        HStack {
            Spacer()
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack(spacing: 5) {
                    Image(systemName: "power")
                        .font(.system(size: 10))
                    Text("Quit SmartClip")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - HoldToDeleteButton

private struct HoldToDeleteButton: View {
    let action: () -> Void
    @State private var isHolding = false
    @State private var showLabel = false
    @State private var progress: CGFloat = 0
    @State private var progressTimer: Timer?
    @State private var didFire = false

    var body: some View {
        HStack(spacing: 6) {
            if showLabel {
                Text("Hold to Delete All")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.35, green: 0.0, blue: 0.0)))
                    .transition(.opacity)
            }

            Image(systemName: "trash")
                .foregroundStyle(isHolding ? Color.red : Color.secondary)
                .overlay {
                    if isHolding {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.red,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 18, height: 18)
                            .animation(.linear(duration: 0.05), value: progress)
                    }
                }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isHolding, !didFire else { return }
                    beginHold()
                }
                .onEnded { _ in
                    didFire = false
                    if progress < 1.0 { cancelHold() }
                }
        )
        .help("Hold 2 seconds to clear all history")
        .onDisappear {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }

    private func beginHold() {
        isHolding = true
        withAnimation(.easeIn(duration: 0.5)) { showLabel = true }
        progress = 0
        let start = Date()
        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { _ in
            let p = min(CGFloat(Date().timeIntervalSince(start) / 2.0), 1.0)
            progress = p
            if p >= 1.0 { finishHold() }
        }
        RunLoop.main.add(t, forMode: .common)
        progressTimer = t
    }

    private func cancelHold() {
        progressTimer?.invalidate()
        progressTimer = nil
        isHolding = false
        withAnimation(.easeOut(duration: 0.15)) { progress = 0 }
        withAnimation(.easeOut(duration: 1.0)) { showLabel = false }
    }

    private func finishHold() {
        progressTimer?.invalidate()
        progressTimer = nil
        didFire = true
        action()
        isHolding = false
        withAnimation(.easeOut(duration: 0.15)) {
            progress = 0
            showLabel = false
        }
    }
}

// MARK: - CategoryPill

private struct CategoryPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(ClipboardStore())
}
