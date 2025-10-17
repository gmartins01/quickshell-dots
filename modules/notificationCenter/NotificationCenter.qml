import qs.config
import qs.services
import qs.modules.widgets
import qs.modules.notificationPopup

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects

StyledPanel {
    id: root

    preferredWidth: 460 // TODO: meter na Appearance
    preferredHeight: 580
    panelBackgroundColor: Colors.colLayer1
    panelKeyboardFocus: true

    panelContent: Item {
        id: notificationCenter

        ColumnLayout {
            id: notificationsRect
            anchors.fill: parent
            anchors.margins: 20//Style.marginL
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

            StyledDivider {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Fundo da lista
                NotificationListView {
                    id: listview
                    anchors.fill: parent

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

                // Placeholder quando não há notificações
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: opacity > 0
                    opacity: (NotificationService.list.length === 0) ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animation.menuDecel.duration
                            easing.type: Appearance.animation.menuDecel.type
                        }
                    }

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
        }
    }
}
