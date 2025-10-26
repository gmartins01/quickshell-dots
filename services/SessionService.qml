pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    property bool hasUwsm: false
    property bool idleInhibited: false
    property string inhibitReason: "Keep system awake"

    property bool locked: false

    Process {
        id: detectUwsmProcess
        running: false
        command: ["which", "uwsm"]

        onExited: function (exitCode) {
            hasUwsm = (exitCode === 0);
        }
    }

    Process {
        id: uwsmLogout
        command: ["uwsm", "stop"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim().toLowerCase().includes("not running")) {
                    _logout();
                }
            }
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                return;
            }
            _logout();
        }
    }

    function logout() {
        if (hasUwsm) {
            uwsmLogout.running = true;
        }
        _logout();
    }

    function _logout() {
        if (CompositorService.isNiri) {
            NiriService.quit();
            return;
        }

        Hyprland.dispatch("exit");
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    signal inhibitorChanged

    function enableIdleInhibit() {
        if (idleInhibited) {
            return;
        }
        console.log("SessionService: Enabling idle inhibit (native:", nativeInhibitorAvailable, ")");
        idleInhibited = true;
        inhibitorChanged();
    }

    function disableIdleInhibit() {
        if (!idleInhibited) {
            return;
        }
        console.log("SessionService: Disabling idle inhibit (native:", nativeInhibitorAvailable, ")");
        idleInhibited = false;
        inhibitorChanged();
    }

    function toggleIdleInhibit() {
        if (idleInhibited) {
            disableIdleInhibit();
        } else {
            enableIdleInhibit();
        }
    }
  
}
