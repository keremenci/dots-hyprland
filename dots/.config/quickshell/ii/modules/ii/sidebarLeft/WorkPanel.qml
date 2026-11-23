import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

/**
 * Work tab: VPN toggle, kubectl context switcher and quick links.
 * - VPN uses ~/.config/hypr/custom/scripts/vpn.sh (section hidden when missing).
 * - Links come from ~/.config/ii-work/links.json, kept outside the dotfiles repo:
 *   [{ "name": "GitLab", "icon": "code", "url": "https://..." },
 *    { "name": "Mission Center", "icon": "monitoring", "command": "missioncenter" }]
 */
Item {
    id: root
    readonly property string home: Quickshell.env("HOME")
    readonly property string vpnScript: `${home}/.config/hypr/custom/scripts/vpn.sh`
    readonly property string linksPath: `${home}/.config/ii-work/links.json`

    property bool vpnAvailable: false
    property string vpnState: "inactive"
    property string vpnAddress: ""
    property string kubeContext: ""
    property var kubeContexts: []
    property var links: []

    function refresh() {
        vpnProc.running = true;
        kubeProc.running = true;
    }
    function shortContext(name) {
        // arn:aws:eks:<region>:<account>:cluster/<name> -> <name>
        const m = name.match(/:cluster\/(.+)$/);
        return m ? m[1] : name;
    }

    onVisibleChanged: if (visible) refresh()
    Component.onCompleted: refresh()

    Timer {
        interval: root.vpnState === "activating" ? 700 : 3000
        running: root.visible
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: vpnProc
        command: ["bash", root.vpnScript, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                root.vpnState = parts[0] || "inactive";
                root.vpnAddress = parts[1] ?? "";
            }
        }
        onExited: exitCode => root.vpnAvailable = exitCode === 0
    }

    Process {
        id: kubeProc
        // Local kubeconfig only; never talks to a cluster
        command: ["bash", "-c", "kubectl config current-context 2>/dev/null; echo ---; kubectl config get-contexts -o name 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [current, rest] = text.split("---\n");
                root.kubeContext = (current ?? "").trim();
                root.kubeContexts = (rest ?? "").split("\n").map(s => s.trim()).filter(s => s.length > 0);
            }
        }
    }

    Process {
        id: useContextProc
        onExited: kubeProc.running = true
    }

    FileView {
        id: linksFile
        path: root.linksPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const parsed = JSON.parse(linksFile.text());
                root.links = Array.isArray(parsed) ? parsed : [];
            } catch (e) {
                console.log("[WorkPanel] Invalid links.json: " + e);
                root.links = [];
            }
        }
        onLoadFailed: error => root.links = []
    }

    component SectionHeader: StyledText {
        Layout.topMargin: 6
        Layout.leftMargin: 4
        font.pixelSize: Appearance.font.pixelSize.smaller
        font.weight: Font.Medium
        color: Appearance.colors.colSubtext
    }

    component ActionRow: RippleButton {
        id: row
        property string iconName
        property string title
        property string subtitle: ""
        property bool current: false
        Layout.fillWidth: true
        implicitHeight: 44
        buttonRadius: Appearance.rounding.small
        colBackground: current ? Appearance.colors.colSecondaryContainer : Appearance.colors.colLayer2
        colBackgroundHover: current ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colLayer2Hover
        colRipple: current ? Appearance.colors.colSecondaryContainerActive : Appearance.colors.colLayer2Active

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10
            MaterialSymbol {
                text: row.iconName
                fill: row.current ? 1 : 0
                iconSize: Appearance.font.pixelSize.larger
                color: row.current ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer2
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    Layout.fillWidth: true
                    text: row.title
                    elide: Text.ElideRight
                    color: row.current ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer2
                }
                StyledText {
                    Layout.fillWidth: true
                    visible: row.subtitle.length > 0
                    text: row.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: row.current ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colSubtext
                }
            }
        }
    }

    StyledFlickable {
        anchors.fill: parent
        anchors.margins: 10
        contentHeight: column.implicitHeight
        clip: true

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 4

            // VPN
            SectionHeader {
                visible: root.vpnAvailable
                text: "VPN"
            }
            ActionRow {
                visible: root.vpnAvailable
                current: root.vpnState === "active"
                iconName: root.vpnState === "active" ? "vpn_lock" : root.vpnState === "activating" ? "vpn_key" : "vpn_key_off"
                title: root.vpnState === "active" ? "Connected" : root.vpnState === "activating" ? "Connecting…" : "Disconnected"
                subtitle: root.vpnState === "active" ? `${root.vpnAddress} · click to disconnect` : "Click to connect (asks for TOTP)"
                onClicked: {
                    Quickshell.execDetached(["bash", root.vpnScript, "toggle"]);
                    root.vpnState = root.vpnState === "active" ? "inactive" : "activating";
                }
            }

            // Kubernetes
            SectionHeader {
                visible: root.kubeContexts.length > 0
                text: "Kubernetes context"
            }
            Repeater {
                model: root.kubeContexts
                delegate: ActionRow {
                    required property string modelData
                    current: modelData === root.kubeContext
                    iconName: "deployed_code"
                    title: root.shortContext(modelData)
                    subtitle: modelData === root.kubeContext ? "current" : ""
                    onClicked: {
                        if (modelData === root.kubeContext) return;
                        useContextProc.command = ["kubectl", "config", "use-context", modelData];
                        useContextProc.running = true;
                    }
                }
            }

            // Links
            SectionHeader {
                text: "Links"
            }
            Repeater {
                model: root.links
                delegate: ActionRow {
                    required property var modelData
                    iconName: modelData.icon ?? (modelData.url ? "open_in_new" : "terminal")
                    title: modelData.name ?? modelData.url ?? modelData.command ?? "?"
                    subtitle: modelData.url ? modelData.url.replace(/^https?:\/\//, "") : ""
                    onClicked: {
                        if (modelData.url) Qt.openUrlExternally(modelData.url);
                        else if (modelData.command) Quickshell.execDetached(["bash", "-c", modelData.command]);
                    }
                }
            }
            ActionRow {
                iconName: "edit"
                title: root.links.length > 0 ? "Edit links" : "Add links"
                subtitle: "~/.config/ii-work/links.json"
                onClicked: Quickshell.execDetached(["bash", "-c",
                    `mkdir -p "$(dirname '${root.linksPath}')"; [ -f '${root.linksPath}' ] || echo '[]' > '${root.linksPath}'; xdg-open '${root.linksPath}'`])
            }
        }
    }
}
