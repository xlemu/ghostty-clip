# ghostty-clip

Clean copy for [Ghostty](https://ghostty.org) terminal.

Fixes the copy-paste problem with [Claude Code](https://claude.ai/claude-code) and other tools that insert hard line-wraps and indentation into terminal output.

## How it works

1. Press **Cmd+Shift+C** to "clean copy" selected text in Ghostty
2. A lightweight background daemon detects the copy, cleans the text, and puts it on your clipboard
3. Paste with **Cmd+V** as normal — no extra spaces, no hard wraps

## What it cleans

- Strips the 2-space indentation Claude Code adds to all output
- Unwraps hard-wrapped paragraphs back into single lines
- Preserves code blocks, bullet points, headings, and blank lines

## Install

Requires macOS 13+ and Xcode Command Line Tools (`xcode-select --install`).

```
git clone https://github.com/<owner>/ghostty-clip
cd ghostty-clip
./install.sh
```

This will:
- Build the binary from source
- Install it to `~/.local/bin/`
- Set up a LaunchAgent (starts at login)
- Add the `Cmd+Shift+C` keybind to your Ghostty config

## Uninstall

```
./uninstall.sh
```

## How it works (technical)

Ghostty's `write_selection_file:copy` action writes the selected text to a temp file and puts the file *path* on the clipboard. `ghostty-clip` watches the clipboard for these paths, reads the file, applies text cleaning rules, and replaces the clipboard with the cleaned content.

No third-party dependencies — just Swift + Apple frameworks (Foundation, AppKit).

## License

MIT
