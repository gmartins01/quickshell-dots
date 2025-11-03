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

    preferredWidth: 560 // TODO: meter na Appearance
    preferredHeight: 480
    panelBackgroundColor: Colors.colLayer1
    panelKeyboardFocus: true

    panelContent: Item {
        id: controlCenterContent

        // AudioSlider {
        //     anchors.centerIn: parent
        //     width: 100//parent.width
        //     height: 14
        // }
        Binding {
            target: root
            property: "preferredHeight"
            value: column.implicitHeight + 15
        }
        ColumnLayout {
            id:column
            anchors.fill: parent
            anchors.margins: 10
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
                id: slidersRow

                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 15
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                // Rectangle {
                //     color: "#FFF"
                //     Layout.fillWidth: true
                //     height: 50
                // }
                // Rectangle {
                //     color: "red"
                //     Layout.fillWidth: true
                //
                //     height: 50
                // }

                AudioSlider {
                    Layout.fillWidth: true
                    // width: 150//parent.width
                    Layout.preferredWidth: parent.width / 2
                }

                BrightnessSlider {
                    // width: 150//parent.width
                    Layout.fillWidth: true

                    Layout.preferredWidth: parent.width / 2
                }
            }

            VolumeWidget {
                Layout.fillWidth: true

                // Layout.fillHeight: true

                Layout.preferredHeight: 180//parent.width / 2
            }
            RowLayout {
                id: slidersRowTest

                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 15
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                Rectangle {
                    color: "#FFF"
                    Layout.fillWidth: true
                    height: 50
                }

                Rectangle {
                    color: "red"
                    Layout.fillWidth: true

                    height: 50
                }
            }
            RowLayout {
                id: sli3dersRowTest

                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 15
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                Rectangle {
                    color: "#FFF"
                    Layout.fillWidth: true
                    height: 50
                }

                Rectangle {
                    color: "red"
                    Layout.fillWidth: true

                    height: 50
                }
            }
            RowLayout {
                id: slidersRowTes3t

                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 15
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                Rectangle {
                    color: "#FFF"
                    Layout.fillWidth: true
                    height: 50
                }

                Rectangle {
                    color: "red"
                    Layout.fillWidth: true

                    height: 50
                }
            }
            RowLayout {
                id: slidersRowTes2t

                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 15
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 0

                Rectangle {
                    color: "#FFF"
                    Layout.fillWidth: true
                    height: 50
                }

                Rectangle {
                    color: "red"
                    Layout.fillWidth: true

                    height: 50
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
