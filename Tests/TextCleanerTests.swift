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
