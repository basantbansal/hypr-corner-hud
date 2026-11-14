import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    property bool expanded: false
    property real animProgress: expanded ? 1.0 : 0.0
    property bool windowActive: expanded || animProgress > 0.05

    // Only claim space when expanded; when collapsed, remain tiny so no buttons are blocked
    implicitWidth: windowActive ? 200 : (clockText.implicitWidth + 16)
    implicitHeight: windowActive ? 200 : 26

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "corner-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Click-through when collapsed: passes clicks through to browser window/menu buttons
    mask: Region {
        item: windowActive ? mainContainer : cornerHotspot
    }

    Behavior on animProgress {
        NumberAnimation {
            duration: root.expanded ? 220 : 70
            easing.type: root.expanded ? Easing.OutCubic : Easing.InCubic
        }
    }

    // --- Status Polling (Wi-Fi, Bluetooth & Airplane Mode) ---
    property bool wifiConnected: false
    property bool btPowered: false
    property bool airplaneMode: false

    Process {
        id: statusPoller
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE dev | grep -q '^wifi:connected' && echo 'wifi:yes' || echo 'wifi:no'; bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo 'bt:yes' || echo 'bt:no'; rfkill list | grep -q 'Soft blocked: yes' && echo 'plane:yes' || echo 'plane:no'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("wifi:yes") !== -1) wifiConnected = true;
                if (data.indexOf("wifi:no") !== -1) wifiConnected = false;
                if (data.indexOf("bt:yes") !== -1) btPowered = true;
                if (data.indexOf("bt:no") !== -1) btPowered = false;
                if (data.indexOf("plane:yes") !== -1) airplaneMode = true;
                if (data.indexOf("plane:no") !== -1) airplaneMode = false;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statusPoller.running) statusPoller.running = true;
        }
    }

    // --- Action Runner ---
    Process {
        id: actionRunner
    }

    function runCmd(cmdList) {
        actionRunner.command = cmdList;
        actionRunner.running = true;
    }

    function keepOpen() {
        hideTimer.stop();
    }

    function queueClose() {
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 180
        repeat: false
        onTriggered: {
            root.expanded = false;
        }
    }

    // Socket/IPC listener for keyboard shortcut toggle
    IpcHandler {
        target: "corner-hud"
        function toggle() {
            root.expanded = !root.expanded;
        }
    }

    Item {
        id: mainContainer
        anchors.fill: parent

        // 1. Frosted Obsidian Quarter-Circle Arc
        Rectangle {
            id: arcBg
            width: 185 * 2
            height: 185 * 2
            radius: 185
            x: parent.width - 185
            y: -185

            color: "#9e1e1e20"
            border.color: "#29ffffff"
            border.width: 1.0

            transformOrigin: Item.TopRight
            scale: root.animProgress
            opacity: root.animProgress
            visible: opacity > 0.01
        }

        // Inner orbit accent
        Rectangle {
            width: 110 * 2
            height: 110 * 2
            radius: 110
            x: parent.width - 110
            y: -110

            color: "transparent"
            border.color: "#38ffffff"
            border.width: 1.0

            transformOrigin: Item.TopRight
            scale: root.animProgress
            opacity: root.animProgress
            visible: opacity > 0.01
        }

        // 2. Clock
        Text {
            id: clockText
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 4
            anchors.rightMargin: 12

            color: "#ffffff"
            font.pixelSize: 11
            font.bold: true
            font.family: "JetBrainsMono Nerd Font, monospace"

            text: " " + Qt.formatDateTime(new Date(), "hh:mm:ss")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: { var now = new Date(); clockText.text = " " + Qt.formatDateTime(now, "hh:mm:ss"); dateText.text = " " + Qt.formatDateTime(now, "ddd, dd MMM"); }
            }
        }

        // 3. Date text
        Text {
            id: dateText
            anchors.top: clockText.bottom
            anchors.right: parent.right
            anchors.topMargin: 3
            anchors.rightMargin: 12

            color: "#ffffff"
            font.pixelSize: 10
            font.bold: true
            font.family: "JetBrainsMono Nerd Font, monospace"
            text: " " + Qt.formatDateTime(new Date(), "ddd, dd MMM")

            opacity: root.animProgress
            visible: opacity > 0.05
            scale: root.animProgress
            transformOrigin: Item.TopRight
        }

        // --- Radial Buttons (R = 138px) ---

        // Wi-Fi (18 deg)
        Item {
            id: wifiContainer
            opacity: root.animProgress
            visible: opacity > 0.05
            scale: (wifiMouse.containsMouse ? 1.15 : 1.0) * root.animProgress
            Behavior on scale { NumberAnimation { duration: 120 } }

            x: parent.width - 138 * Math.cos(18 * Math.PI / 180) - width/2
            y: 138 * Math.sin(18 * Math.PI / 180) - height/2
            width: 34; height: 34

            Rectangle {
                anchors.fill: parent
                radius: 17
                color: wifiMouse.containsMouse
                       ? (root.wifiConnected ? "#38bdf8" : "#55ffffff")
                       : (root.wifiConnected ? "#1a38bdf8" : "#1a1a20")
                border.color: root.wifiConnected ? "#38bdf8" : "#25ffffff"
                border.width: 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: root.wifiConnected ? "" : "󰖪"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font, monospace"
                color: wifiMouse.containsMouse && root.wifiConnected
                       ? "#0f172a"
                       : (root.wifiConnected ? "#38bdf8" : "#60ffffff")
            }

            MouseArea {
                id: wifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: keepOpen()
                onPositionChanged: keepOpen()
                onExited: queueClose()
                onClicked: {
                    runCmd(["nm-connection-editor"]);
                    root.expanded = false;
                }
            }
        }

        // Bluetooth (45 deg)
        Item {
            id: btContainer
            opacity: root.animProgress
            visible: opacity > 0.05
            scale: (btMouse.containsMouse ? 1.15 : 1.0) * root.animProgress
            Behavior on scale { NumberAnimation { duration: 120 } }

            x: parent.width - 138 * Math.cos(45 * Math.PI / 180) - width/2
            y: 138 * Math.sin(45 * Math.PI / 180) - height/2
            width: 34; height: 34

            Rectangle {
                anchors.fill: parent
                radius: 17
                color: btMouse.containsMouse
                       ? (root.btPowered ? "#38bdf8" : "#55ffffff")
                       : (root.btPowered ? "#1a38bdf8" : "#1a1a20")
                border.color: root.btPowered ? "#38bdf8" : "#25ffffff"
                border.width: 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: root.btPowered ? "" : "󰂲"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font, monospace"
                color: btMouse.containsMouse && root.btPowered
                       ? "#0f172a"
                       : (root.btPowered ? "#38bdf8" : "#60ffffff")
            }

            MouseArea {
                id: btMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: keepOpen()
                onPositionChanged: keepOpen()
                onExited: queueClose()
                onClicked: {
                    runCmd(["blueman-manager"]);
                    root.expanded = false;
                }
            }
        }

        // Airplane Mode (72 deg)
        Item {
            id: planeContainer
            opacity: root.animProgress
            visible: opacity > 0.05
            scale: (planeMouse.containsMouse ? 1.15 : 1.0) * root.animProgress
            Behavior on scale { NumberAnimation { duration: 120 } }

            x: parent.width - 138 * Math.cos(72 * Math.PI / 180) - width/2
            y: 138 * Math.sin(72 * Math.PI / 180) - height/2
            width: 34; height: 34

            Rectangle {
                anchors.fill: parent
                radius: 17
                color: planeMouse.containsMouse
                       ? (root.airplaneMode ? "#f59e0b" : "#55ffffff")
                       : (root.airplaneMode ? "#33f59e0b" : "#1a1a20")
                border.color: root.airplaneMode ? "#f59e0b" : "#25ffffff"
                border.width: 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: "✈"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font, monospace"
                color: planeMouse.containsMouse && root.airplaneMode
                       ? "#0f172a"
                       : (root.airplaneMode ? "#f59e0b" : "#60ffffff")
            }

            MouseArea {
                id: planeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: keepOpen()
                onPositionChanged: keepOpen()
                onExited: queueClose()
                onClicked: {
                    if (root.airplaneMode) {
                        runCmd(["rfkill", "unblock", "all"]);
                    } else {
                        runCmd(["rfkill", "block", "all"]);
                    }
                    statusPoller.running = true;
                }
            }
        }

        // --- Hover Management ---

        // 1. Precise corner trigger
        MouseArea {
            id: cornerHotspot
            anchors.top: parent.top
            anchors.right: parent.right
            width: 8
            height: 8
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                keepOpen();
                root.expanded = true;
            }
        }

        // 2. Arc Body Tracker
        MouseArea {
            id: hudTracker
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            enabled: root.expanded
            z: -1

            onEntered: keepOpen()
            onPositionChanged: mouse => {
                var dx = mouse.x - parent.width;
                var dy = mouse.y;
                var dist = Math.sqrt(dx * dx + dy * dy);
                if (dist <= 195) {
                    keepOpen();
                } else {
                    queueClose();
                }
            }
            onExited: queueClose()
        }
    }
}
