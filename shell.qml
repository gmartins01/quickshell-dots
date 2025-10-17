//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication

// import qs.modules//"./modules/"
import "./modules/bar/"
import "./modules/background/"
import "./modules/calendar/"
import "./modules/notificationPopup/"
import "./modules/notificationCenter/"
import "./modules/common/"
import "./services/"

import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtCore

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
        id: notificationHistoryPanel
        objectName: "notificationHistoryPanel"
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
