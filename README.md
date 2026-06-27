# SmartClipboard

A macOS menu bar app that remembers everything you copy — with smart categorization, search, and instant re-copy.

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey) ![License](https://img.shields.io/badge/license-MIT-blue) ![Swift](https://img.shields.io/badge/swift-5.9-orange)

---

## Features

- **Clipboard history** — every item you copy is saved and accessible from the menu bar
- **Smart categorization** — automatically detects and labels content as URL, Email, JSON, Phone, Color, Code, or Text
- **Filter by category** — narrow down your history to exactly what you're looking for
- **Search** — full-text search across your entire clipboard history
- **One-click re-copy** — click any item to copy it back to your clipboard instantly

## Installation

1. Download `SmartClipboard.zip` from the [latest release](../../releases/latest)
2. Unzip and drag `SmartClipboard.app` to your `/Applications` folder
3. Launch the app — it will appear in your menu bar

> **Note:** SmartClipboard is not notarized with Apple. On first launch, macOS will block it.
> To open: right-click `SmartClipboard.app` → **Open** → click **Open** in the dialog.
> This only needs to be done once.

## Usage

Click the clipboard icon in your menu bar to open the history panel.

| Action | How |
|---|---|
| Re-copy an item | Click it |
| Search history | Type in the search bar |
| Filter by category | Click a category badge (URL, Email, JSON, etc.) |
| Clear history | Right-click → Clear |

## Requirements

- macOS 13 Ventura or later
- Apple Silicon or Intel Mac

## Building from source

```bash
git clone https://github.com/puttdlc/SmartClipboard.git
cd SmartClipboard
open SmartClipboard.xcodeproj
```

Build and run with `⌘R` in Xcode.

## License

MIT — see [LICENSE](LICENSE) for details.