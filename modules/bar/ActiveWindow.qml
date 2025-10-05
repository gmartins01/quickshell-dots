import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

// Item {
//     id: root
//     readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
//     readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
//
//     property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
//     property bool focusingThisMonitor: HyprlandData.activeWorkspace.monitor == monitor.name
//     property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor.id]?.activeWorkspace.id)
//
//     implicitWidth: colLayout.implicitWidth
//
//     ColumnLayout {
//         id: colLayout
//
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.left: parent.left
//         anchors.right: parent.right
//         spacing: -4
//
//         StyledText {
//             Layout.fillWidth: true
//             font.pixelSize: Appearance.font.pixelSize.smaller
//             color: Appearance.colors.colSubtext
//             elide: Text.ElideRight
//             text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.appId : (root.biggestWindow?.class) ?? "Desktop"
//         }
//
//         StyledText {
//             Layout.fillWidth: true
//             font.pixelSize: Appearance.font.pixelSize.small
//             color: Appearance.colors.colOnLayer0
//             elide: Text.ElideRight
//
//             property int maxChars: 50
//
//             text: {
//                 let title = root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.title : (root.biggestWindow?.title ?? `Workspace ${monitor.activeWorkspace?.id}`);
//
//                 if (title && title.length > maxChars) {
//                     return title.slice(0, maxChars) + "…";
//                 }
//                 return title;
//             }
//         }
//     }
// }

Item {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property var parentScreen
    property bool compactMode: false
    property int availableWidth: 400
    property real widgetThickness: 30
    readonly property real horizontalPadding: 20
    readonly property int baseWidth: 200//contentRow.implicitWidth + horizontalPadding * 2
    readonly property int maxNormalWidth: 456
    readonly property int maxCompactWidth: 288
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    property var activeDesktopEntry: null

    implicitWidth: colLayout.implicitWidth

    Component.onCompleted: {
        updateDesktopEntry();
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root.updateDesktopEntry();
        }
    }

    Connections {
        target: root
        function onActiveWindowChanged() {
            root.updateDesktopEntry();
        }
    }

    function updateDesktopEntry() {
        if (activeWindow && activeWindow.appId) {
            const moddedId = activeWindow.appId;
            activeDesktopEntry = DesktopEntries.heuristicLookup(moddedId);
        } else {
            activeDesktopEntry = null;
        }
    }
    readonly property bool hasWindowsOnCurrentWorkspace: {
        // if (CompositorService.isNiri) {
        //     let currentWorkspaceId = null;
        //     for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
        //         const ws = NiriService.allWorkspaces[i];
        //         if (ws.is_focused) {
        //             currentWorkspaceId = ws.id;
        //             break;
        //         }
        //     }
        //
        //     if (!currentWorkspaceId) {
        //         return false;
        //     }
        //
        //     const workspaceWindows = NiriService.windows.filter(w => w.workspace_id === currentWorkspaceId);
        //     return workspaceWindows.length > 0 && activeWindow && activeWindow.title;
        // }

        if (CompositorService.isHyprland) {
            if (!Hyprland.focusedWorkspace || !activeWindow || !activeWindow.title) {
                return false;
            }

            const hyprlandToplevels = Array.from(Hyprland.toplevels.values);
            const activeHyprToplevel = hyprlandToplevels.find(t => t.wayland === activeWindow);

            if (!activeHyprToplevel || !activeHyprToplevel.workspace) {
                return false;
            }

            return activeHyprToplevel.workspace.id === Hyprland.focusedWorkspace.id;
        }

        return activeWindow && activeWindow.title;
    }


    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -4

        StyledText {
            id: appText

            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Colors.colors.colSubtext
            elide: Text.ElideRight
            text: {
                if(!hasWindowsOnCurrentWorkspace) {
                    return "Desktop"
                }

                if (!activeWindow || !activeWindow.appId)
                    return "?";
                if (activeDesktopEntry && activeDesktopEntry.name) {
                    return activeDesktopEntry.name;
                }
                return activeWindow.appId;
            }
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Colors.colors.colOnLayer0
            elide: Text.ElideRight

            property int maxChars: 50

            text: {
                const title = activeWindow && activeWindow.title ? activeWindow.title : "";
                const appName = appText.text;
                let result = "";

                if (!title || !appName) {
                    result = title;
                } else if (title.endsWith(" - " + appName)) {
                    result = title.substring(0, title.length - (" - " + appName).length);
                } else if (title.endsWith(appName)) {
                    result = title.substring(0, title.length - appName.length).replace(/ - $/, "");
                } else {
                    result = title;
                }

                if (result.length > maxChars) {
                    result = result.substring(0, maxChars - 3) + "...";
                }

                return result;
            }
        }
    }
}
