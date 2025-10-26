import qs.services

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property alias lock: lock

    // This stores all the information shared between the lock surfaces on each screen.
    LockContext {
        id: lockContext

        onUnlocked: {
            // Unlock the screen before exiting, or the compositor will display a
            // fallback lock you can't interact with.
            lock.locked = false;

            // Qt.quit();
        }
    }

    WlSessionLock {
        id: lock

        // Lock the session immediately when quickshell starts.
        // locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    Connections {
        target: IdleService

        function onLockRequested() {
            lock.locked = true;
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            lock.locked = true;
        }

        function unlock(): void {
            lock.unlock();
        }

        function isLocked(): bool {
            return lock.locked;
        }
    }
}
