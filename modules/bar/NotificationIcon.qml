import qs.config
import qs.utils
import qs.services
import qs.modules.widgets

import QtQuick

RippleButton {
    id: root

    implicitWidth: icon.implicitWidth + 10 * 2
    implicitHeight: icon.implicitHeight + 5 * 2

    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Colors.colLayer1Hover
    colRipple: Colors.colLayer1Active
    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive

    toggled: PanelService.isPanelOpen("notificationCenter")

    onClicked: {
        const panel = PanelService.getPanel("notificationCenter");
        NotificationService.timeoutAll();
        NotificationService.markAllRead();
        panel?.toggle(this);
    }

    MaterialIcon {
        id: icon
        anchors.centerIn: parent
        iconSize: Appearance.font.pixelSize.larger
        text: Icons.getNotificationIcon(NotificationService.silent)
        horizontalAlignment: Text.AlignHCenter
        color: Colors.colOnLayer2

        Rectangle {
            id: notifPing
            visible: NotificationService.unread > 0
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: root.showUnreadCount ? 0 : 0
                topMargin: root.showUnreadCount ? 0 : 1
            }
            radius: Appearance.rounding.full
            color: Colors.m3colors.m3error
            z: 1

            implicitHeight: Math.max(notificationCounterText.implicitWidth, notificationCounterText.implicitHeight)
            implicitWidth: implicitHeight

            StyledText {
                id: notificationCounterText
                anchors.centerIn: parent
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Colors.m3colors.m3onError
                text: NotificationService.unread
            }
        }
    }

    // Loader {
    //     anchors.right: parent.right
    //     anchors.top: parent.top
    //     anchors.rightMargin: 3
    //     anchors.topMargin: 3
    //     z: 2
    //     active: NotificationService.unread > 0
    //     sourceComponent: Rectangle {
    //         id: badge
    //         readonly property int count: NotificationService.list.length
    //         readonly property string label: count <= 99 ? String(count) : "99+"
    //         readonly property real pad: 8
    //         height: 12
    //         width: Math.max(height, textNode.implicitWidth + pad)
    //         radius: height / 2
    //         color: Colors.m3colors.m3error
    //         border.color: Colors.m3colors.m3surface
    //         border.width: 1
    //         visible: NotificationService.list.length > 0
    //         StyledText {
    //             id: textNode
    //             anchors.centerIn: parent
    //             text: NotificationService.list.length
    //             font.pixelSize: 2
    //             color: Colors.m3colors.m3onError
    //         }
    //     }
    // }
}
