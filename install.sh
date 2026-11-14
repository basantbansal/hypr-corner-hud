#!/usr/bin/env bash
set -e

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/corner-hud"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Hypr Corner HUD..."

# Create target config directory
mkdir -p "$CONFIG_DIR"

# Symlink shell.qml into config folder
ln -sf "$SCRIPT_DIR/shell.qml" "$CONFIG_DIR/shell.qml"
echo "  ✓ Linked shell.qml -> $CONFIG_DIR/shell.qml"

# Make daemon script executable
chmod +x "$SCRIPT_DIR/CornerHudDaemon.sh"
echo "  ✓ Made CornerHudDaemon.sh executable"

# Dependency checks
echo "==> Checking dependencies..."
check_cmd() {
    local cmd="$1"
    local pkg="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✓ $cmd found"
    else
        echo "  ⚠ $cmd not found (recommended package: $pkg)"
    fi
}

check_cmd quickshell "quickshell"
check_cmd nmcli "networkmanager"
check_cmd nm-connection-editor "network-manager-applet"
check_cmd bluetoothctl "bluez-utils"
check_cmd blueman-manager "blueman"
check_cmd rfkill "rfkill / util-linux"

echo ""
echo "Installation complete!"
echo "To test run:"
echo "  quickshell -p $CONFIG_DIR"
echo ""
echo "To add autostart in hyprland.conf:"
echo "  exec-once = $SCRIPT_DIR/CornerHudDaemon.sh"
