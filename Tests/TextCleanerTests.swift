import Testing
@testable import ghostty_clip

@Test func stripsLeadingTwoSpaceIndent() {
    let input = "  Hello world\n  Second line\n"
    let result = cleanText(input)
    #expect(result.contains("Hello world"))
    #expect(!result.hasPrefix(" "))
}

@Test func preservesContentAfterIndent() {
    let input = "  func hello() {\n      return true\n  }\n"
    let result = cleanText(input)
    #expect(result.contains("func hello() {"))
    #expect(result.contains("    return true"))
    #expect(result.contains("}"))
}

@Test func handlesNoIndent() {
    let input = "No indent here\n"
    let result = cleanText(input)
    #expect(result == "No indent here\n")
}

@Test func unwrapsHardWrappedParagraph() {
    let input = """
      This is a long line that was hard
      wrapped by Claude Code at the
      terminal width.

    """
    let result = cleanText(input)
    #expect(result == "This is a long line that was hard wrapped by Claude Code at the terminal width.\n")
}

@Test func preservesBlankLineParagraphBreaks() {
    let input = "  First paragraph.\n\n  Second paragraph.\n"
    let result = cleanText(input)
    #expect(result.contains("First paragraph.\n\n"))
    #expect(result.contains("Second paragraph."))
}

@Test func preservesBulletPoints() {
    let input = "  - Item one\n  - Item two\n  - Item three\n"
    let result = cleanText(input)
    #expect(result == "- Item one\n- Item two\n- Item three\n")
}

@Test func preservesOrderedLists() {
    let input = "  1. First\n  2. Second\n"
    let result = cleanText(input)
    #expect(result == "1. First\n2. Second\n")
}

@Test func preservesHeadings() {
    let input = "  # Title\n  Some text under\n  the title.\n"
    let result = cleanText(input)
    #expect(result == "# Title\nSome text under the title.\n")
}

@Test func preservesCodeFenceContents() {
    let input = """
      ```bash
      echo "hello"
        nested indent
      ```

    """
    let result = cleanText(input)
    let expected = """
    ```bash
    echo "hello"
      nested indent
    ```

    """
    #expect(result == expected)
}

@Test func doesNotUnwrapInsideCodeFences() {
    let input = "  ```\n  line one\n  line two\n  ```\n"
    let result = cleanText(input)
    #expect(result == "```\nline one\nline two\n```\n")
}

@Test func handlesTrailingWhitespace() {
    let input = "  Hello   \n  World   \n"
    let result = cleanText(input)
    #expect(!result.contains("   \n"))
}

@Test func hashTagIsNotAHeading() {
    let input = "  Here is #tag and #123 inline.\n"
    let result = cleanText(input)
    #expect(result == "Here is #tag and #123 inline.\n")
}

@Test func codeFencePreservesTrailingSpaces() {
    let input = "  ```\n  line with spaces   \n  ```\n"
    let result = cleanText(input)
    #expect(result == "```\nline with spaces   \n```\n")
}

@Test func emptyInputReturnsEmpty() {
    let result = cleanText("")
    #expect(result == "")
}

@Test func noTrailingNewlinePreserved() {
    let input = "  Hello world"
    let result = cleanText(input)
    #expect(result == "Hello world")
    #expect(!result.hasSuffix("\n"))
}

@Test func preservesCodeWithoutFences() {
    let input = "  def fibonacci(n):\n      if n <= 1:\n          return n\n      a, b = 0, 1\n      return b\n"
    let result = cleanText(input)
    #expect(result == "def fibonacci(n):\n    if n <= 1:\n        return n\n    a, b = 0, 1\n    return b\n")
}

@Test func doesNotJoinAfterCodeTerminators() {
    let input = "  function hello():\n  world\n"
    let result = cleanText(input)
    #expect(result == "function hello():\nworld\n")
}

@Test func doesNotJoinIndentedLines() {
    let input = "  first line\n      indented line\n  back to normal\n"
    let result = cleanText(input)
    #expect(result.contains("first line\n"))
    #expect(result.contains("    indented line\n"))
}

@Test func stillUnwrapsProseWithoutFences() {
    let input = "  This is a long paragraph that was\n  wrapped by the terminal at some\n  arbitrary width.\n"
    let result = cleanText(input)
    #expect(result == "This is a long paragraph that was wrapped by the terminal at some arbitrary width.\n")
}

// --- Real-world Claude Code output patterns (from terminal screenshots) ---

@Test func realWorldNumberedListWithWrappedItems() {
    // From screenshot: numbered list where items wrap to next line with extra indent
    let input = """
      1. **Shorter, punchier.** You cut the "merchants need
      does.
      2. **No over-explaining.** You dropped implementation
      "Pashov audit". The reviewer doesn't need that in
      3. **Functions listed cleanly** on their own line, no
      4. **Each bullet is one thing**, clearly separated. N

    """
    let result = cleanText(input)
    // Each numbered item should stay separate, wrapped continuations should join
    #expect(result.hasPrefix("1. **Shorter, punchier.**"))
    #expect(result.contains("2. **No over-explaining.**"))
    #expect(result.contains("3. **Functions listed cleanly**"))
    #expect(result.contains("4. **Each bullet is one thing**"))
}

@Test func realWorldProseFollowedByList() {
    // From screenshot: "Yes. Yours is better because:" then a numbered list
    let input = "  Yes. Yours is better because:\n\n  1. Shorter\n  2. Punchier\n"
    let result = cleanText(input)
    #expect(result == "Yes. Yours is better because:\n\n1. Shorter\n2. Punchier\n")
}

@Test func realWorldProseAfterList() {
    // From screenshot: list items followed by standalone prose
    let input = "  5. **Used some dashes** but sparingly and well.\n\n  I'll match this style going forward.\n"
    let result = cleanText(input)
    #expect(result.contains("5. **Used some dashes**"))
    #expect(result.contains("\n\nI'll match this style going forward."))
}

@Test func realWorldDashListWithWrappedItems() {
    // Bullet list where items wrap across lines
    let input = "  - Mixed prose and code (no fences) in the same\n    selection\n  - JavaScript/Go/Rust style code\n  - Nested bullet points\n"
    let result = cleanText(input)
    // The wrapped "selection" line has leading whitespace after strip, stays separate
    #expect(result.contains("- Mixed prose and code"))
    #expect(result.contains("- JavaScript/Go/Rust"))
    #expect(result.contains("- Nested bullet points"))
}

@Test func realWorldMixedProseAndCode() {
    // Prose paragraph, then inline code-like content, then more prose
    let input = "  Run the install with `./install.sh` and then\n  verify it works by pressing Cmd+Shift+C.\n\n  The binary is only 63KB.\n"
    let result = cleanText(input)
    #expect(result.hasPrefix("Run the install with `./install.sh` and then verify it works by pressing Cmd+Shift+C."))
    #expect(result.contains("\n\nThe binary is only 63KB."))
}

@Test func realWorldJavaScriptCode() {
    let input = "  function greet(name) {\n      console.log(`Hello ${name}`);\n      return true;\n  }\n"
    let result = cleanText(input)
    #expect(result == "function greet(name) {\n    console.log(`Hello ${name}`);\n    return true;\n}\n")
}

@Test func realWorldGoCode() {
    let input = "  func main() {\n      fmt.Println(\"hello\")\n  }\n"
    let result = cleanText(input)
    #expect(result == "func main() {\n    fmt.Println(\"hello\")\n}\n")
}

@Test func realWorldBoldAndInlineCode() {
    // Bold text and inline code shouldn't affect cleaning
    let input = "  **Important:** Use `Cmd+Shift+C` instead of\n  the normal `Cmd+C` for clean copy.\n"
    let result = cleanText(input)
    #expect(result == "**Important:** Use `Cmd+Shift+C` instead of the normal `Cmd+C` for clean copy.\n")
}

@Test func realWorldMultipleParagraphs() {
    let input = "  First paragraph that wraps across\n  two lines in the terminal.\n\n  Second paragraph also wraps\n  across lines.\n\n  Third short one.\n"
    let result = cleanText(input)
    #expect(result == "First paragraph that wraps across two lines in the terminal.\n\nSecond paragraph also wraps across lines.\n\nThird short one.\n")
}

@Test func detectsGhosttySelectionPath() {
    let path = "/private/var/folders/f4/g4kyjvqj2gq4qgw35njypxjm0000gn/T/mJi1pPsplKktRlE6Is7AEQ/selection.txt"
    #expect(isGhosttySelectionPath(path) == true)
}

@Test func detectsPathWithTrailingNewline() {
    let path = "/private/var/folders/ab/cd1234/T/randomdir/selection.txt\n"
    #expect(isGhosttySelectionPath(path) == true)
}

@Test func rejectsNormalText() {
    #expect(isGhosttySelectionPath("Hello world") == false)
    #expect(isGhosttySelectionPath("some code here") == false)
}

@Test func rejectsMultilinePaths() {
    let multi = "/private/var/folders/ab/cd/T/dir/selection.txt\nmore stuff"
    #expect(isGhosttySelectionPath(multi) == false)
}

@Test func rejectsWrongFilename() {
    let path = "/private/var/folders/ab/cd/T/dir/screen.txt"
    #expect(isGhosttySelectionPath(path) == false)
}
