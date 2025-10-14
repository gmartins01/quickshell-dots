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

    preferredWidth: 460 // TODO: meter na Appearance
    preferredHeight: 580
    panelKeyboardFocus: true

    panelContent: Item {
        id: notificationCenter

        ColumnLayout {
            id: notificationsRect
            anchors.fill: parent
            anchors.margins: 10//Style.marginL
            // color: "transparent"

            // Header
            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 10//Style.marginM

                StyledText {
                    text: "Notifications"
                    // font.weight: Style.fontWeightBold
                    font.pixelSize: 20
                    color: Colors.m3colors.m3onSurface
                    Layout.fillWidth: true
                }

                ButtonGroup {
                    id: controls
                    Layout.alignment: Qt.AlignRight
                    // anchors.right: parent.right
                    // anchors.verticalCenter: parent.verticalCenter
                    // anchors.rightMargin: 5

                    NotificationStatusButton {
                        buttonIcon: "notifications_paused"
                        buttonText: "Silent"
                        toggled: NotificationService.silent
                        onClicked: () => {
                            NotificationService.silent = !NotificationService.silent;
                        }
                    }
                    NotificationStatusButton {
                        buttonIcon: "clear_all"
                        buttonText: "Clear"
                        onClicked: () => {
                            NotificationService.discardAllNotifications();
                        }
                    }
                }
            }

            NotificationListView { // Scrollable window
                id: listview
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10

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
                Layout.fillWidth: true
                Layout.fillHeight: true

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
              

                Layout.fillWidth: true
                implicitHeight: Math.max(controls.implicitHeight, statusText.implicitHeight)

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
}
