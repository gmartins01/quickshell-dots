pragma ComponentBehavior: Bound

import "lock"
import qs.config
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland


Scope {
    id: root

    required property Lock lock
    readonly property bool enabled: true//!Config.general.idle.inhibitWhenAudio || !Players.list.some(p => p.isPlaying)

    function handleIdleAction(action: var): void {
        if (!action)
            return;

        if (action === "lock")
            lock.lock.locked = true;
        else if (action === "unlock")
            lock.lock.locked = false;
        else if (typeof action === "string")
            Hyprland.dispatch(action);
        else
            Quickshell.execDetached(action);
    }

    // LogindManager {
    //     onAboutToSleep: {
    //         if (Config.general.idle.lockBeforeSleep)
    //             root.lock.lock.locked = true;
    //     }
    //     onLockRequested: root.lock.lock.locked = true
    //     onUnlockRequested: root.lock.lock.unlock()
    // }

    // Variants {
    //     model: Config.general.idle.timeouts

    IdleMonitor {
        // required property var modelData

        enabled: root.enabled //&& (modelData.enabled ?? true)
        timeout: 10//modelData.timeout
        respectInhibitors: true//modelData.respectInhibitors ?? true
        onIsIdleChanged: root.handleIdleAction("lock")
    }

    IdleMonitor {
        // required property var modelData

        enabled: root.enabled //&& (modelData.enabled ?? true)
        timeout: 20//modelData.timeout
        respectInhibitors: true//modelData.respectInhibitors ?? true
        onIsIdleChanged: root.handleIdleAction(isIdle ? "dpms off" : "dpms on")
    }
    // }
}
