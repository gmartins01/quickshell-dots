import qs.config
import qs.services
import qs.modules.widgets

import QtQuick

RippleButton {
    id: root

    property bool showPing: false
    property var popupTarget: null
    property var parentScreen: null

    property real buttonPadding: 5
    implicitWidth: icon.width + buttonPadding * 2
    implicitHeight: icon.height + buttonPadding * 2
    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Colors.colors.colLayer1Hover
    colRipple: Colors.colors.colLayer1Active
    colBackgroundToggled: Colors.colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colors.colSecondaryContainerHover
    colRippleToggled: Colors.colors.colSecondaryContainerActive

    signal notifIconClicked

    onClicked: {
        const panel = PanelService.getPanel("notificationHistoryPanel");
        panel?.toggle(this);
    }

    MaterialIcon {
        id: icon
        anchors.centerIn: parent
        iconSize: Appearance.font.pixelSize.larger
        text: "Notifications"
        horizontalAlignment: Text.AlignHCenter
        color: Colors.colOnLayer2
    }

    Loader {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 3
        anchors.topMargin: 3
        z: 2
        active: NotificationService.list.length > 0
        sourceComponent: Rectangle {
            id: badge
            readonly property int count: NotificationService.list.length
            readonly property string label: count <= 99 ? String(count) : "99+"
            readonly property real pad: 8
            height: 12
            width: Math.max(height, textNode.implicitWidth + pad)
            radius: height / 2
            color: Colors.m3colors.m3error
            border.color: Colors.m3colors.m3surface
            border.width: 1
            visible: NotificationService.list.length > 0
            StyledText {
                id: textNode
                anchors.centerIn: parent
                text: NotificationService.list.length
                font.pixelSize: 2
                color: Colors.m3colors.m3onError
            }
        }
    }
}
