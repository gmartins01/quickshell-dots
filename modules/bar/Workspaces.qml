import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

Rectangle {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property string screenName: ""
    property real widgetHeight: 30

    // width: isVertical ? widgetHeight : (workspaceRow.implicitWidth + padding * 2)
    // height: isVertical ? (workspaceRow.implicitHeight + padding * 2) : widgetHeight
    radius: 8
    color: {
        return "transparent";
    }
    visible: CompositorService.isNiri || CompositorService.isHyprland
    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: 35

    property int currentWorkspace: {
        if (CompositorService.isNiri) {
            return getNiriActiveWorkspace();
        } else if (CompositorService.isHyprland) {
            return getHyprlandActiveWorkspace();
        }
        return 1;
    }
    property var workspaceList: {
        if (CompositorService.isNiri) {
            const baseList = getNiriWorkspaces();
            return baseList;//SettingsData.showWorkspacePadding ? padWorkspaces(baseList) : baseList;
        }
        if (CompositorService.isHyprland) {
            const baseList = getHyprlandWorkspaces();
            return baseList;//SettingsData.showWorkspacePadding ? padWorkspaces(baseList) : baseList;
        }
        return [1];
    }

    function getWorkspaceIcons(ws) {
        if (!SettingsData.showWorkspaceApps || !ws) {
            return [];
        }

        let targetWorkspaceId;
        if (CompositorService.isNiri) {
            const wsNumber = typeof ws === "number" ? ws : -1;
            if (wsNumber <= 0) {
                return [];
            }
            const workspace = NiriService.allWorkspaces.find(w => w.idx + 1 === wsNumber && w.output === root.screenName);
            if (!workspace) {
                return [];
            }
            targetWorkspaceId = workspace.id;
        } else if (CompositorService.isHyprland) {
            targetWorkspaceId = ws.id !== undefined ? ws.id : ws;
        } else {
            return [];
        }

        const wins = CompositorService.isNiri ? (NiriService.windows || []) : CompositorService.sortedToplevels;

        const byApp = {};
        const isActiveWs = CompositorService.isNiri ? NiriService.allWorkspaces.some(ws => ws.id === targetWorkspaceId && ws.is_active) : targetWorkspaceId === root.currentWorkspace;

        wins.forEach((w, i) => {
            if (!w) {
                return;
            }

            let winWs = null;
            if (CompositorService.isNiri) {
                winWs = w.workspace_id;
            } else {
                // For Hyprland, we need to find the corresponding Hyprland toplevel to get workspace
                const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || []);
                const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === w);
                winWs = hyprToplevel?.workspace?.id;
            }

            if (winWs === undefined || winWs === null || winWs !== targetWorkspaceId) {
                return;
            }

            const keyBase = (w.app_id || w.appId || w.class || w.windowClass || "unknown").toLowerCase();
            const key = isActiveWs ? `${keyBase}_${i}` : keyBase;

            if (!byApp[key]) {
                const moddedId = Paths.moddedAppId(keyBase);
                const isSteamApp = moddedId.toLowerCase().includes("steam_app");
                const icon = isSteamApp ? "" : Quickshell.iconPath(DesktopEntries.heuristicLookup(moddedId)?.icon, true);
                byApp[key] = {
                    "type": "icon",
                    "icon": icon,
                    "isSteamApp": isSteamApp,
                    "active": !!(w.activated || (CompositorService.isNiri && w.is_focused)),
                    "count": 1,
                    "windowId": w.address || w.id,
                    "fallbackText": w.appId || w.class || w.title || ""
                };
            } else {
                byApp[key].count++;
                if (w.activated || (CompositorService.isNiri && w.is_focused)) {
                    byApp[key].active = true;
                }
            }
        });

        return Object.values(byApp);
    }

    function padWorkspaces(list) {
        const padded = list.slice();
        const placeholder = CompositorService.isHyprland ? {
            "id": -1,
            "name": ""
        } : -1;
        while (padded.length < 3) {
            padded.push(placeholder);
        }
        return padded;
    }

    function getNiriWorkspaces() {
        if (NiriService.allWorkspaces.length === 0) {
            return [1, 2];
        }

        if (!root.screenName) {
            //|| !SettingsData.workspacesPerMonitor) {
            return NiriService.getCurrentOutputWorkspaceNumbers();
        }

        const displayWorkspaces = NiriService.allWorkspaces.filter(ws => ws.output === root.screenName).map(ws => ws.idx + 1);
        return displayWorkspaces.length > 0 ? displayWorkspaces : [1, 2];
    }

    function getNiriActiveWorkspace() {
        if (NiriService.allWorkspaces.length === 0) {
            return 1;
        }

        if (!root.screenName) {
            //|| !SettingsData.workspacesPerMonitor) {
            return NiriService.getCurrentWorkspaceNumber();
        }

        const activeWs = NiriService.allWorkspaces.find(ws => ws.output === root.screenName && ws.is_active);
        return activeWs ? activeWs.idx + 1 : 1;
    }

    function getHyprlandWorkspaces() {
        const workspaces = Hyprland.workspaces?.values || [];

        if (!root.screenName) {
            //|| !SettingsData.workspacesPerMonitor) {
            // Show all workspaces on all monitors if per-monitor filtering is disabled
            const sorted = workspaces.slice().sort((a, b) => a.id - b.id);
            return sorted.length > 0 ? sorted : [
                {
                    "id": 1,
                    "name": "1"
                }
            ];
        }

        // Filter workspaces for this specific monitor using lastIpcObject.monitor
        // This matches the approach from the original kyle-config
        const monitorWorkspaces = workspaces.filter(ws => {
            return ws.lastIpcObject && ws.lastIpcObject.monitor === root.screenName;
        });

        if (monitorWorkspaces.length === 0) {
            // Fallback if no workspaces exist for this monitor
            return [
                {
                    "id": 1,
                    "name": "1"
                }
            ];
        }

        // Return all workspaces for this monitor, sorted by ID
        return monitorWorkspaces.sort((a, b) => a.id - b.id);
    }

    function getHyprlandActiveWorkspace() {
        if (!root.screenName) {
            //|| !SettingsData.workspacesPerMonitor) {
            return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;
        }

        // Find the monitor object for this screen
        const monitors = Hyprland.monitors?.values || [];
        const currentMonitor = monitors.find(monitor => monitor.name === root.screenName);

        if (!currentMonitor) {
            return 1;
        }

        // Use the monitor's active workspace ID (like original config)
        return currentMonitor.activeWorkspace?.id ?? 1;
    }

    readonly property real padding: isVertical ? Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30)) : (widgetHeight - workspaceRow.implicitHeight) / 2

    function getRealWorkspaces() {
        return root.workspaceList.filter(ws => {
            if (CompositorService.isHyprland) {
                return ws && ws.id !== -1;
            }
            return ws !== -1;
        });
    }

    function switchWorkspace(direction) {
        if (CompositorService.isNiri) {
            const realWorkspaces = getRealWorkspaces();
            if (realWorkspaces.length < 2) {
                return;
            }

            const currentIndex = realWorkspaces.findIndex(ws => ws === root.currentWorkspace);
            const validIndex = currentIndex === -1 ? 0 : currentIndex;
            const nextIndex = direction > 0 ? (validIndex + 1) % realWorkspaces.length : (validIndex - 1 + realWorkspaces.length) % realWorkspaces.length;

            NiriService.switchToWorkspace(realWorkspaces[nextIndex] - 1);
        } else if (CompositorService.isHyprland) {
            const command = direction > 0 ? "workspace r+1" : "workspace r-1";
            Hyprland.dispatch(command);
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        property real scrollAccumulator: 0
        property real touchpadThreshold: 500

        onWheel: wheel => {
            const deltaY = wheel.angleDelta.y;
            const isMouseWheel = Math.abs(deltaY) >= 120 && (Math.abs(deltaY) % 120) === 0;
            const direction = deltaY > 0 ? 1 : -1;

            if (isMouseWheel) {
                switchWorkspace(direction);
            } else {
                scrollAccumulator += deltaY;

                if (Math.abs(scrollAccumulator) >= touchpadThreshold) {
                    const touchDirection = scrollAccumulator < 0 ? 1 : -1;
                    switchWorkspace(touchDirection);
                    scrollAccumulator = 0;
                }
            }

            wheel.accepted = true;
        }
    }

    Flow {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: Appearance.margins.smaller
        flow: Flow.LeftToRight //isVertical ? Flow.TopToBottom : Flow.LeftToRight

        Repeater {
            model: root.workspaceList

            Rectangle {
                id: delegateRoot

                property bool isActive: {
                    if (CompositorService.isHyprland) {
                        return modelData && modelData.id === root.currentWorkspace;
                    }
                    return modelData === root.currentWorkspace;
                }

                property bool isPlaceholder: {
                    if (CompositorService.isHyprland) {
                        return modelData && modelData.id === -1;
                    }
                    return modelData === -1;
                }

                property bool isHovered: mouseArea.containsMouse

                property var loadedWorkspaceData: null
                property bool loadedIsUrgent: false
                property bool isUrgent: {
                    if (CompositorService.isHyprland) {
                        return modelData?.urgent ?? false;
                    }
                    if (CompositorService.isNiri) {
                        return loadedIsUrgent;
                    }
                    return false;
                }

                Timer {
                    id: dataUpdateTimer
                    interval: 50
                    onTriggered: {
                        if (isPlaceholder) {
                            delegateRoot.loadedWorkspaceData = null;
                            delegateRoot.loadedIsUrgent = false;
                            return;
                        }

                        var wsData = null;
                        if (CompositorService.isNiri) {
                            wsData = NiriService.allWorkspaces.find(ws => ws.idx + 1 === modelData && ws.output === root.screenName) || null;
                        } else if (CompositorService.isHyprland) {
                            wsData = modelData;
                        }
                        delegateRoot.loadedWorkspaceData = wsData;
                        delegateRoot.loadedIsUrgent = wsData?.is_urgent ?? false;
                    }
                }

                function updateAllData() {
                    dataUpdateTimer.restart();
                }

                implicitWidth: root.widgetHeight * 0.5
                implicitHeight: root.widgetHeight * 0.7
                color: "transparent"

                Rectangle {
                    id: background
                    anchors.fill: parent
                    radius: 4

                    color: (isActive || isUrgent) ? Colors.colPrimary : isPlaceholder ? Colors.colTertiary : "transparent"//Colors.m3colors.m3primary
                }

                Loader {
                    id: indexLoader
                    anchors.fill: parent
                    active: !isPlaceholder
                    sourceComponent: Item {
                        StyledText {
                            anchors.centerIn: parent
                            text: {
                                const isPlaceholder = CompositorService.isHyprland ? (modelData?.id === -1) : (modelData === -1);
                                if (isPlaceholder) {
                                    return index + 1;
                                }
                                return CompositorService.isHyprland ? (modelData?.id || "") : (modelData - 1);
                            }
                            color: (isActive || isUrgent) ? Colors.colOnPrimary : isPlaceholder ? Colors.colTertiary : Colors.colPrimary
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: (isActive && !isPlaceholder) ? Font.DemiBold : Font.Normal
                        }
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height //+ Theme.spacingXL
                    hoverEnabled: !isPlaceholder
                    cursorShape: isPlaceholder ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: !isPlaceholder
                    onClicked: {
                        if (isPlaceholder) {
                            return;
                        }

                        if (CompositorService.isNiri) {
                            NiriService.switchToWorkspace(modelData - 1);
                        } else if (CompositorService.isHyprland && modelData?.id) {
                            Hyprland.dispatch(`workspace ${modelData.id}`);
                        }
                    }
                }

                Connections {
                    target: CompositorService
                    function onSortedToplevelsChanged() {
                        delegateRoot.updateAllData();
                    }
                }
                Connections {
                    target: NiriService
                    enabled: CompositorService.isNiri
                    function onAllWorkspacesChanged() {
                        delegateRoot.updateAllData();
                    }
                    function onWindowUrgentChanged() {
                        delegateRoot.updateAllData();
                    }
                }
            }
        }
    }
}
