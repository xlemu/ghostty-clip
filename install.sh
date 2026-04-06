#!/bin/bash
set -euo pipefail

BINARY_NAME="ghostty-clip"
INSTALL_DIR="$HOME/.local/bin"
AGENT_DIR="$HOME/Library/LaunchAgents"
AGENT_NAME="com.ghostty-clip"
LOG_DIR="$HOME/.local/share/ghostty-clip"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
KEYBIND_LINE="keybind = cmd+shift+c=write_selection_file:copy"

echo "==> Building ghostty-clip..."
swift build -c release

BUILT_BINARY=".build/release/$BINARY_NAME"
if [ ! -f "$BUILT_BINARY" ]; then
    echo "ERROR: Build failed — binary not found at $BUILT_BINARY"
    exit 1
fi

echo "==> Installing binary to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "$BUILT_BINARY" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "==> Installing LaunchAgent..."
mkdir -p "$AGENT_DIR"
mkdir -p "$LOG_DIR"

PLIST="$AGENT_DIR/$AGENT_NAME.plist"
sed \
    -e "s|__BINARY_PATH__|$INSTALL_DIR/$BINARY_NAME|g" \
    -e "s|__HOME__|$HOME|g" \
    com.ghostty-clip.plist > "$PLIST"

# Unload if already loaded (ignore errors)
launchctl unload "$PLIST" 2>/dev/null || true

echo "==> Loading LaunchAgent..."
launchctl load "$PLIST"

echo "==> Configuring Ghostty keybind..."
if [ -f "$GHOSTTY_CONFIG" ]; then
    if ! grep -qF "$KEYBIND_LINE" "$GHOSTTY_CONFIG"; then
        echo "" >> "$GHOSTTY_CONFIG"
        echo "# ghostty-clip: clean copy keybind" >> "$GHOSTTY_CONFIG"
        echo "$KEYBIND_LINE" >> "$GHOSTTY_CONFIG"
        echo "   Added keybind to $GHOSTTY_CONFIG"
    else
        echo "   Keybind already present in $GHOSTTY_CONFIG"
    fi
else
    echo "   WARNING: Ghostty config not found at $GHOSTTY_CONFIG"
    echo "   Add this line manually: $KEYBIND_LINE"
fi

echo ""
echo "==> ghostty-clip installed!"
echo "   Binary:      $INSTALL_DIR/$BINARY_NAME"
echo "   LaunchAgent: $PLIST"
echo "   Logs:        $LOG_DIR/ghostty-clip.log"
echo ""
echo "   Use Cmd+Shift+C in Ghostty for clean copy."
echo "   Reload Ghostty config (Cmd+Shift+,) to activate the keybind."
