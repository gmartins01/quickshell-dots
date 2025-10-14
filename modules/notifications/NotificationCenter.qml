import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects

// Notification History panel
StyledPanel {
    id: root

    preferredWidth: 380
    preferredHeight: 480
    panelKeyboardFocus: true

    panelContent: Item {
        id: notificationRect
        // color: "#FFF"//Color.transparent

        NotificationListView { // Scrollable window
            id: listview
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: statusRow.top
            anchors.bottomMargin: 5

            clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: listview.width
                    height: listview.height
                    radius: Appearance.rounding.normal
                }
            }

            popup: false
        }

        // Placeholder when list is empty
        Item {
            anchors.fill: listview

            visible: opacity > 0
            opacity: (NotificationService.list.length === 0) ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.animation.menuDecel.duration
                    easing.type: Appearance.animation.menuDecel.type
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconSize: 55
                    color: Colors.m3colors.m3outline
                    text: "notifications_active"
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Colors.m3colors.m3outline
                    horizontalAlignment: Text.AlignHCenter
                    text: "No notifications"
                }
            }
        }

        Item {
            id: statusRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Layout.fillWidth: true
            implicitHeight: statusText.implicitHeight//Math.max(controls.implicitHeight, statusText.implicitHeight)

            StyledText {
                id: statusText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                horizontalAlignment: Text.AlignHCenter
                text: NotificationService.list.length

                opacity: NotificationService.list.length > 0 ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }
    }
}
