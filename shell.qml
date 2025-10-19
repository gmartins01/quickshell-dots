//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication

import qs.services
import qs.modules.bar
import qs.modules.background
import qs.modules.calendar
import qs.modules.notificationPopup
import qs.modules.notificationCenter

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

    LazyLoader {
        active: enableReloadPopup
        component: ReloadPopup {}
    }

    Background {}
}
