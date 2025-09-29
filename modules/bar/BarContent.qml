import qs
import qs.utils
import qs.services
import qs.config
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property ShellScreen screen

    // Background shadow
    // Loader {
    //     active: true//Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1
    //     anchors.fill: barBackground
    //     sourceComponent: StyledRectangularShadow {
    //         anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
    //         target: barBackground
    //     }
    // }

    Component.onCompleted: {
        console.log("TESTE", screen);
    }

    // Background
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            margins: 0//Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0 // idk why but +1 is needed
        }
        color: Colors.m3colors.m3background//Config.options.bar.showBackground ? Appearance.colors.colLayer0 : "transparent"
        radius: 0//Config.options.bar.cornerStyle === 1 ? Appearance.rounding.windowRounding : 0
        border.width: 0//Config.options.bar.cornerStyle === 1 ? 1 : 0
        border.color: Colors.m3colors.m3background//Appearance.colors.colLayer0Border
    }

    RowLayout {
        id: leftSection

        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: Appearance.margins.small
        anchors.verticalCenter: parent.verticalCenter

        DistroIcon {
            Layout.alignment: Qt.AlignVCenter
            // Layout.leftMargin: Appearance.rounding.screenRounding
        }

        HyprlandWorkspaces {
            monitorName: root.screen.name
        }

        // Rectangle {
        //     Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        //     Layout.preferredWidth: 35
        //     Layout.preferredHeight: 35
        //
        //     radius: 5
        //     color: Colors.m3colors.m3primary
        //     Text {
        //         anchors.centerIn: parent
        //         text: ""
        //         font.family: "Jetbrains Mono NF"
        //
        //         color: "#181926"
        //         font.pixelSize: 20
        //         font.weight: 300
        //     }
        //
        //     MouseArea {
        //         anchors.fill: parent
        //         hoverEnabled: true
        //         cursorShape: Qt.PointingHandCursor
        //
        //         //onEntered: parent.color = "#B7BCF8"
        //         //onExited: parent.color = "#B7BCF8"
        //         //onClicked: banging
        //     }
        // }
    }

    RowLayout {
        id: middleSection

        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // spacing: 4

        MaterialIcon {
            //Layout.rightMargin: indicatorsRowLayout.realSpacing
            text: NetworkService.active ? Icons.getNetworkIcon(NetworkService.active.strength ?? 0) : "signal_wifi_off"
            iconSize: Appearance.font.pixelSize.larger
            color: Colors.colors.colOnLayer0 // toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
        }
    }

    RowLayout {
        id: rightSection

        height: parent.height
        anchors.right: parent.right//barBackground.right
        anchors.rightMargin: Appearance.margins.small
        anchors.verticalCenter: barBackground.verticalCenter
        spacing: 4

        SysTray {
            visible: true//root.useShortenedForm === 0
            Layout.fillWidth: false
            Layout.fillHeight: true
            invertSide: Settings?.options.bar.position === "bottom"
        }

        StyledText {
            text: `${Math.round(AudioService.volume * 100)}%`
        }

        ClockWidget {
            showDate: false
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }
}
