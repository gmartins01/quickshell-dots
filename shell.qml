//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication

import qs.services
import qs.modules
import qs.modules.bar
import qs.modules.background
import qs.modules.calendar
import qs.modules.notificationPopup
import qs.modules.notificationCenter
import qs.modules.controlCenter
import qs.modules.OSD
import qs.modules.lock

import Quickshell
import QtQuick
import QtQuick

ShellRoot {
    property bool enableBar: true
    property bool enableReloadPopup: false
    property bool enableNotifications: true
    property bool enableNotificationPopup: true

    LazyLoader {
        active: enableBar
        component: Bar {}
    }

    Component.onCompleted: {
        ColorsService.init();
    }

    NotificationPopup {
        id: notificationPopup
    }

    NotificationCenter {
        id: notificationCenter
        objectName: "notificationCenter"
    }

    CalendarWidget {
        id: calendarPanel
        objectName: "calendarPanel"
    }

    Variants {
        model: Quickshell.screens

        delegate: VolumeOSD {
            modelData: item
        }
    }

    LazyLoader {
        active: enableReloadPopup
        component: ReloadPopup {}
    }

    Background {}

    Lock {
        id: lock
    }

    ControlCenter {
        id: controlCenter
        objectName: "controlCenter"
    }

    // IdleMonitors {
    //     lock: lock
    // }
}
