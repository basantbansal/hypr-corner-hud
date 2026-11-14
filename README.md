# 🚀 Hypr Corner HUD

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Quickshell](https://img.shields.io/badge/Quickshell-Qt6%20%2F%20QML-orange.svg)](https://quickshell.outfoxxed.me/)
[![Platform](https://img.shields.io/badge/Platform-Wayland%20%2F%20Hyprland-blueviolet.svg)](https://hyprland.org/)

A sleek, lightweight, frosted-glass corner HUD and quick-settings radial widget designed for **Hyprland** and Wayland compositors, built with [Quickshell](https://quickshell.outfoxxed.me/).

<p align="center">
  <img src="assets/demo.gif" alt="Hypr Corner HUD Demo" width="340" />
</p>

---

## ✨ Features

- **Frosted Obsidian Radial Arc**: Smooth quarter-circle arc seamlessly docked into the top-right screen corner.
- **Minimal Idle Footprint**: Displays an elegant digital clock in the corner when collapsed without cluttering your desktop.
- **Smart Click-Through Mask**: The window region masks out transparent areas when idle, ensuring your browser tabs, window control buttons, and status bars are never blocked.
- **Quick Settings Radial Controls**:
  - 📶 **Wi-Fi**: Live connection indicator with click-to-open network connection manager (`nm-connection-editor`).
  - 󰂯 **Bluetooth**: Real-time power status with click-to-launch Bluetooth manager (`blueman-manager`).
  - ✈️ **Airplane Mode**: One-click radio blocker toggle (`rfkill block/unblock all`).
- **Interactive Hover & Proximity Tracking**: Expands smoothly when hovering the top-right corner hotspot (or over the radial arc body) and auto-closes with easing.
- **IPC Hotkey Support**: Integrated `IpcHandler` allows toggling the HUD on and off via Hyprland keybindings (`quickshell ipc call corner-hud toggle`).
- **Process Supervisor Daemon**: Lightweight shell daemon with `flock` locking to ensure single-instance reliability and auto-restart.

---

## 📦 Requirements & Dependencies

Ensure the following packages are installed on your system:

| Component | Required Package | Description |
|---|---|---|
| **Shell Framework** | `quickshell` | High-performance Wayland desktop shell library (QtQuick / QML) |
| **Compositor** | `hyprland` | Wayland compositor with `wlr-layer-shell` support |
| **Font** | `ttf-jetbrains-mono-nerd` | Nerd font glyphs for clock, calendar, and status icons |
| **Networking** | `networkmanager`, `network-manager-applet` | `nmcli` for status queries, `nm-connection-editor` for Wi-Fi settings |
| **Bluetooth** | `bluez`, `bluez-utils`, `blueman` | `bluetoothctl` for polling, `blueman-manager` for device pairing |
| **Wireless Killswitch** | `util-linux` / `rfkill` | Airplane mode toggle |

> **Arch Linux users:**
> ```bash
> sudo pacman -S quickshell ttf-jetbrains-mono-nerd networkmanager network-manager-applet bluez bluez-utils blueman util-linux
> ```

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/basantbansal/hypr-corner-hud.git
cd hypr-corner-hud
```

### 2. Run the Installer

Run the included install script to link the QML configuration to `~/.config/corner-hud` and configure permissions:

```bash
./install.sh
```

*(Alternatively, you can manually symlink `shell.qml`:)*
```bash
mkdir -p ~/.config/corner-hud
ln -sf "$(pwd)/shell.qml" ~/.config/corner-hud/shell.qml
chmod +x CornerHudDaemon.sh
```

---

## ⚙️ Hyprland Integration

Add the following lines to your `hyprland.conf` (typically located at `~/.config/hypr/hyprland.conf`):

### Autostart Daemon

```ini
# Start Hypr Corner HUD daemon on login
exec-once = /path/to/hypr-corner-hud/CornerHudDaemon.sh
```
*(Replace `/path/to/hypr-corner-hud/` with the actual path where you cloned this repository).*

### Keyboard Shortcut (Optional)

You can bind any hotkey to toggle the corner HUD via Quickshell IPC:

```ini
# Toggle Corner HUD (Super + C)
bind = $mainMod, C, exec, quickshell -p ~/.config/corner-hud ipc call corner-hud toggle
```

---

## 🎮 Usage

- **Hover to Expand**: Move your cursor to the top-right corner of the screen (hotspot area) to trigger the radial expansion.
- **Click Actions**:
  - Click **Wi-Fi** icon: Opens Network Connection Editor.
  - Click **Bluetooth** icon: Opens Blueman Bluetooth Manager.
  - Click **Airplane** icon: Toggles Airplane mode on/off.
- **Auto Collapse**: Move your mouse cursor outside the radial arc boundary to smoothly collapse the HUD back to minimal clock mode.
- **Keybind Toggle**: Press your configured Hyprland keybinding to open or close the HUD instantly.

---

## 📁 Repository Structure

```text
hypr-corner-hud/
├── assets/              # Demo video and animated preview GIF
│   ├── demo.gif
│   └── demo.mp4
├── CornerHudDaemon.sh   # Background supervisor ensuring single instance
├── shell.qml            # Quickshell LayerShell UI & logic
├── install.sh           # Helper script for setup & dependency verification
├── .gitignore           # Git ignore patterns
├── LICENSE              # MIT License
└── README.md            # Project documentation
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/basantbansal/hypr-corner-hud/issues) if you have any ideas or bug reports.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.
