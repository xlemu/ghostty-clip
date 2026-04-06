import AppKit
import Foundation


func processClipboard() {
    let pasteboard = NSPasteboard.general
    guard let content = pasteboard.string(forType: .string) else { return }

    guard isGhosttySelectionPath(content) else { return }

    let path = content.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let data = FileManager.default.contents(atPath: path),
          let text = String(data: data, encoding: .utf8) else {
        fputs("ghostty-clip: could not read \(path)\n", stderr)
        return
    }

    try? FileManager.default.removeItem(atPath: path)

    let cleaned = cleanText(text)

    pasteboard.clearContents()
    pasteboard.setString(cleaned, forType: .string)

    fputs("ghostty-clip: cleaned \(text.count) -> \(cleaned.count) chars\n", stderr)
}

// Main run loop
fputs("ghostty-clip: watching clipboard...\n", stderr)

var lastChangeCount = NSPasteboard.general.changeCount

let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
    let current = NSPasteboard.general.changeCount
    if current != lastChangeCount {
        lastChangeCount = current
        processClipboard()
        // Update after our own write so we don't re-trigger
        lastChangeCount = NSPasteboard.general.changeCount
    }
}

RunLoop.main.run()
