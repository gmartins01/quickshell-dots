pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // Generic compositor properties
    property string compositor: "unknown" // "hyprland", "niri", or "unknown"
    property bool isHyprland: false
    property bool isNiri: false

    readonly property string hyprlandSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")

    property int focusedWindowIndex: -1
    property string focusedWindowTitle: "n/a"

    Component.onCompleted: {
        detectCompositor();
        // updateActiveWorkspace();
    }

    function detectCompositor() {
        if (hyprlandSignature && hyprlandSignature.length > 0) {
            isHyprland = true;
            isNiri = false;
            compositor = "hyprland";
            console.log("CompositorService: Detected Hyprland");
            return;
        }

        if (niriSocket && niriSocket.length > 0) {
            niriSocketCheck.running = true;
        } else {
            isHyprland = false;
            isNiri = false;
            compositor = "unknown";
            console.warn("CompositorService: No compositor detected");
        }
    }

    function getFocusedWindow() {
        if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.length) {
            return windows[focusedWindowIndex];
        }
        return null;
    }
}
