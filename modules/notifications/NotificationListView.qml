import qs
import qs.config
import qs.modules.widgets
import qs.services

import QtQuick
import Quickshell

StyledListView { // Scrollable window
    id: root
    property bool popup: false

    spacing: 3

    model: ScriptModel {
        values: root.popup ? NotificationService.popupAppNameList : NotificationService.appNameList
    }
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        anchors.left: parent?.left
        anchors.right: parent?.right
        notificationGroup: popup ? 
            NotificationService.popupGroupsByAppName[modelData] :
            NotificationServoce.groupsByAppName[modelData]
    }
}
