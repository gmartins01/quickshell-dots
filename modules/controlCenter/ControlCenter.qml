import qs.config
import qs.modules.widgets
import "components"

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.widgets
import "components"

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

StyledPanel {
    id: root

    preferredWidth: 780 // TODO: meter na Appearance
    preferredHeight: 580
    panelBackgroundColor: Colors.colLayer1
    panelKeyboardFocus: true

    panelContent: Item {
        id: controlCenterContent

        // AudioSlider {
        //     anchors.centerIn: parent
        //     width: 100//parent.width
        //     height: 14
        // }

        BrightnessSlider {
            anchors.centerIn: parent
            width: 100//parent.width

            height: 14
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            RowLayout {
                Layout.fillHeight: false
                spacing: 12
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                CustomIcon {
                    id: distroIcon
                    width: 25
                    height: 25
                    source: "nixos-symbolic"//SystemInfo.distroIcon
                    colorize: true
                    color: Colors.colOnLayer0
                }

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Colors.colOnLayer0
                    text: "TESTE"
                    textFormat: Text.MarkdownText
                }
                Item {
                    Layout.fillWidth: true
                }

                ButtonGroup {
                    QuickToggleButton {
                        toggled: false
                        buttonIcon: "restart_alt"
                        onClicked: {
                            Quickshell.reload(true);
                        }
                        StyledToolTip {
                            text: "Reload Quickshell"
                        }
                    }
                    QuickToggleButton {
                        toggled: false
                        buttonIcon: "settings"
                        // onClicked: {
                        //     Quickshell.execDetached(["qs", "-p", root.settingsQmlPath]);
                        // }
                        StyledToolTip {
                            text: "Settings"
                        }
                    }
                    QuickToggleButton {
                        toggled: false
                        buttonIcon: "power_settings_new"
                        onClicked: {
                            Quickshell.execDetached(["qs", "ipc", "call", "session", "open"]);
                            // GlobalStates.sessionOpen = true;
                            // GlobalStates.sessionOpen = true;
                        }
                        StyledToolTip {
                            text: "Session"
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 12
                Layout.margins: 20
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                AudioSlider {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width / 2
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
