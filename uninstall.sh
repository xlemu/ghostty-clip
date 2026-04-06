#!/bin/bash
set -euo pipefail

BINARY_NAME="ghostty-clip"
INSTALL_DIR="$HOME/.local/bin"
AGENT_DIR="$HOME/Library/LaunchAgents"
AGENT_NAME="com.ghostty-clip"
LOG_DIR="$HOME/.local/share/ghostty-clip"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

PLIST="$AGENT_DIR/$AGENT_NAME.plist"

echo "==> Unloading LaunchAgent..."
launchctl unload "$PLIST" 2>/dev/null || true

echo "==> Removing files..."
rm -f "$PLIST"
rm -f "$INSTALL_DIR/$BINARY_NAME"
rm -rf "$LOG_DIR"

echo "==> Removing Ghostty keybind..."
if [ -f "$GHOSTTY_CONFIG" ]; then
    sed -i '' '/# ghostty-clip: clean copy keybind/d' "$GHOSTTY_CONFIG"
    sed -i '' '/keybind = cmd+shift+c=write_selection_file:copy/d' "$GHOSTTY_CONFIG"
    echo "   Removed keybind from $GHOSTTY_CONFIG"
fi

echo ""
echo "==> ghostty-clip uninstalled."
