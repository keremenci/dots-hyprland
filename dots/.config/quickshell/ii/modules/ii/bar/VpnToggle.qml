import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

// Work VPN toggle. Backed by ~/.config/hypr/custom/scripts/vpn.sh; hidden when that script is missing.
RippleButton {
    id: root
    readonly property string script: `${Quickshell.env("HOME")}/.config/hypr/custom/scripts/vpn.sh`
    property bool available: false
    property string vpnState: "inactive" // active | activating | inactive
    property string address: ""
    readonly property bool connected: vpnState === "active"

    visible: available
    implicitHeight: 26
    implicitWidth: implicitHeight
    buttonRadius: Appearance.rounding.full
    colBackground: connected ? Appearance.colors.colSecondaryContainer : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
    colBackgroundHover: connected ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colLayer1Hover
    colRipple: Appearance.colors.colLayer1Active

    onClicked: {
        Quickshell.execDetached(["bash", root.script, "toggle"]);
        pollTimer.interval = 500; // follow the transition closely for a bit
        fastPollReset.restart();
    }

    contentItem: MaterialSymbol {
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        fill: root.connected ? 1 : 0
        text: root.connected ? "vpn_lock" : root.vpnState === "activating" ? "vpn_key" : "vpn_key_off"
        iconSize: Appearance.font.pixelSize.larger
        color: root.connected ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
        opacity: root.vpnState === "activating" ? 0.6 : 1
    }

    StyledToolTip {
        text: root.connected ? `VPN connected: ${root.address}` : root.vpnState === "activating" ? "VPN connecting…" : "VPN off (click to connect)"
    }

    Process {
        id: statusProc
        command: ["bash", root.script, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                root.vpnState = parts[0] || "inactive";
                root.address = parts[1] ?? "";
            }
        }
        onExited: (exitCode) => root.available = exitCode === 0
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }
    Timer {
        id: fastPollReset
        interval: 30000
        onTriggered: pollTimer.interval = 2000
    }
}
