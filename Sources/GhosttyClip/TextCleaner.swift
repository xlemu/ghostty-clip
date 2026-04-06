private let ghosttyPattern = "/private/var/folders/"
private let ghosttyFilename = "selection.txt"

func isGhosttySelectionPath(_ string: String) -> Bool {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.hasPrefix(ghosttyPattern)
        && trimmed.hasSuffix(ghosttyFilename)
        && !trimmed.contains("\n")
}

func cleanText(_ input: String) -> String {
    var lines = input.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

    lines = lines.map { line in
        if line.hasPrefix("  ") {
            return String(line.dropFirst(2))
        }
        return line
    }

    var result: [String] = []
    var inCodeFence = false
    var paragraphBuffer: [String] = []

    func flushParagraph() {
        if !paragraphBuffer.isEmpty {
            result.append(paragraphBuffer.joined(separator: " "))
            paragraphBuffer = []
        }
    }

    for line in lines {
        if line.hasPrefix("```") {
            flushParagraph()
            inCodeFence.toggle()
            result.append(line)
            continue
        }

        if inCodeFence {
            result.append(line)
            continue
        }

        let line = line.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)

        if line.isEmpty {
            flushParagraph()
            result.append(line)
            continue
        }

        if isStructuralLine(line) {
            flushParagraph()
            result.append(line)
            continue
        }

        paragraphBuffer.append(line)
    }

    flushParagraph()

    var output = result.joined(separator: "\n")

    if input.hasSuffix("\n") && !output.hasSuffix("\n") {
        output.append("\n")
    }

    return output
}

func isStructuralLine(_ line: String) -> Bool {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
        return true
    }
    if trimmed.hasPrefix("# ") || trimmed == "#" {
        return true
    }
    if let first = trimmed.first, first.isNumber {
        let rest = trimmed.drop(while: { $0.isNumber })
        if rest.hasPrefix(". ") || rest.hasPrefix(") ") {
            return true
        }
    }
    return false
}
