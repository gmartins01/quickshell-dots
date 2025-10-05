import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
// import Quickshell.Hyprland

Item {
    id: root
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
    property bool focusingThisMonitor: HyprlandData.activeWorkspace.monitor == monitor.name
    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor.id]?.activeWorkspace.id)

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -4

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.appId : (root.biggestWindow?.class) ?? "Desktop"
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight

            property int maxChars: 50

            text: {
                let title = root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.title : (root.biggestWindow?.title ?? `Workspace ${monitor.activeWorkspace?.id}`);

                if (title && title.length > maxChars) {
                    return title.slice(0, maxChars) + "…";
                }
                return title;
            }
        }
    }
}
