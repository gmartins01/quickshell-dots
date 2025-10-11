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
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(screen)

    // Background shadow
    // Loader {
    //     active: true//Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1
    //     anchors.fill: barBackground
    //     sourceComponent: StyledRectangularShadow {
    //         anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
    //         target: barBackground
    //     }
    // }

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

        ActiveWindow {
            Layout.fillWidth: false
            Layout.fillHeight: true
            parentScreen: root.screen
        }
    }

    RowLayout {
        id: middleSection

        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Workspaces {
            screenName: root.screen.name
            widgetHeight: 40//barWindow.widgetThickness
        }
    }

    RowLayout {
        id: rightSection

        height: parent.height
        anchors.right: parent.right//barBackground.right
        anchors.rightMargin: Appearance.margins.small
        anchors.verticalCenter: barBackground.verticalCenter
        spacing: 10

        SysTray {
            visible: true//root.useShortenedForm === 0
            Layout.fillWidth: false
            Layout.fillHeight: true
            invertSide: Settings?.options.bar.position === "bottom"
        }

        MaterialIcon {
            id: volumeIcon

            text: Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
            iconSize: Appearance.font.pixelSize.larger
            color: Colors.colors.colOnLayer0

            WheelHandler {
                target: volumeIcon
                onWheel: event => {
                    const current = AudioService.sink.audio.volume;
                    const step = current < 0.1 ? 0.01 : 0.02;
                    if (event.angleDelta.y < 0)
                        AudioService.sink.audio.volume = Math.max(0, current - step);
                    else if (event.angleDelta.y > 0)
                        AudioService.sink.audio.volume = Math.min(1, current + step);
                }
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            }
        }

        StyledText {
            text: `${Math.round(AudioService.volume * 100)}%`
        }

        MaterialIcon {
            //Layout.rightMargin: indicatorsRowLayout.realSpacing
            text: NetworkService.active ? Icons.getNetworkIcon(NetworkService.active.strength ?? 0) : "signal_wifi_off"
            iconSize: Appearance.font.pixelSize.larger
            color: Colors.colors.colOnLayer0 // toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
        }

        ClockWidget {
            showDate: false
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }
}
