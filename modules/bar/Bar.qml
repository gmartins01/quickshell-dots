import qs.modules.common
import qs.config

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray

Scope {
    id: bar

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: true

            required property ShellScreen modelData

            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData

                WlrLayershell.namespace: "quickshell:bar"
                implicitHeight: Appearance.sizes.barHeight

                color: "transparent"

                anchors {
                    top: !Settings.options.bar.bottom
                    left: true
                    right: true
                    bottom: Settings.options.bar.bottom
                }

                BarContent {
                    id: barContent

                    screen: barLoader.modelData

                    implicitHeight: Appearance.sizes.barHeight

                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.top
                        bottom: undefined
                        topMargin: 0
                        bottomMargin: 0
                        rightMargin: 0
                    }
                }
            }
        }

        // PanelWindow {
        //     id: barWindow
        //     property var modelData
        //     screen: modelData
        //
        //     property string screenName: modelData.name
        //
        //     anchors {
        //         top: !Settings.options.bar.bottom
        //         left: true
        //         right: true
        //         bottom: Settings.options.bar.bottom
        //     }
        //
        //     color: "transparent"
        //
        //     implicitHeight: barBase.height
        //
        //     // Rectangle {
        //     //     id: barBase
        //     //     //anchors.top: parent.top
        //     //     //anchors.topMargin: 0
        //     //     height: 45
        //     //     anchors.fill: parent
        //     //     //width: parent.width
        //     //     color: Colors.m3colors.m3background
        //     //
        //     //     RowLayout {
        //     //         height: 10
        //     //         spacing: 10
        //     //         anchors.left: parent.left
        //     //         anchors.top: parent.top
        //     //         anchors.bottom: parent.bottom
        //     //
        //     //         anchors.topMargin: 5
        //     //         anchors.bottomMargin: 10
        //     //         anchors.leftMargin: 15
        //     //
        //     //         Rectangle {
        //     //             Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        //     //             Layout.preferredWidth: 35
        //     //             Layout.preferredHeight: 35
        //     //
        //     //             radius: 5
        //     //             color: Colors.m3colors.m3primary
        //     //             Text {
        //     //                 anchors.centerIn: parent
        //     //                 text: ""
        //     //                 font.family: "Jetbrains Mono NF"
        //     //
        //     //                 color: "#181926"
        //     //                 font.pixelSize: 20
        //     //                 font.weight: 300
        //     //             }
        //     //
        //     //             MouseArea {
        //     //                 anchors.fill: parent
        //     //                 hoverEnabled: true
        //     //                 cursorShape: Qt.PointingHandCursor
        //     //
        //     //                 //onEntered: parent.color = "#B7BCF8"
        //     //                 //onExited: parent.color = "#B7BCF8"
        //     //                 //onClicked: banging
        //     //             }
        //     //         }
        //     //
        //     //         HyprlandWorkspaces {
        //     //             monitorName: barWindow.screenName
        //     //         }
        //     //     }
        //     //
        //     //     RowLayout {
        //     //         height: 10
        //     //         spacing: 20
        //     //         anchors.right: parent.right
        //     //         anchors.top: parent.top
        //     //         anchors.bottom: parent.bottom
        //     //
        //     //         anchors.topMargin: 5
        //     //         anchors.bottomMargin: 10
        //     //         anchors.rightMargin: 10
        //     //
        //     //         SysTray {
        //     //             Layout.preferredWidth: (SystemTray.items.values.length * 25)
        //     //
        //     //             bar: barWindow
        //     //         }
        //     //         TimeWidget {}
        //     //     }
        //     // }
        // }
    }
}
