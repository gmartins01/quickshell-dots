import qs.utils
import qs.services
import qs.config
import qs.modules.widgets
import qs.modules.bar.systray

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
        color: Colors.colLayer0 //Config.options.bar.showBackground ? Appearance.colors.colLayer0 : "transparent"
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
            screenName: root.screen?.name
            widgetHeight: 45//barWindow.widgetThickness
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

        NotificationIcon {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: 5//Appearance.rounding.screenRounding
            Layout.fillWidth: false
        }

        StyledText {
            text: `${Math.round(AudioService.volume * 100)}%`
        }

        RippleButton {

            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: 5//Appearance.rounding.screenRounding
            Layout.fillWidth: false

            implicitWidth: indicatorsRowLayout.implicitWidth + 10 * 2
            implicitHeight: indicatorsRowLayout.implicitHeight + 5 * 2

            buttonRadius: Appearance.rounding.full
            colBackground: ColorUtils.transparentize(Colors.colLayer1Hover, 1) //barRightSideMouseArea.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            colBackgroundHover: Colors.colLayer1Hover
            colRipple: Colors.colLayer1Active
            colBackgroundToggled: Colors.colSecondaryContainer
            colBackgroundToggledHover: Colors.colSecondaryContainerHover
            colRippleToggled: Colors.colSecondaryContainerActive
            // toggled: GlobalStates.sidebarRightOpen
            property color colText: Colors.colOnLayer0//toggled ? Colors.m3colors.m3onSecondaryContainer : Colors.colOnLayer0

            Behavior on colText {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            RowLayout {
                id: indicatorsRowLayout
                anchors.centerIn: parent
                property real realSpacing: 15
                spacing: 0
                MaterialIcon {
                    id: volumeIcon

                    text: Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
                    iconSize: Appearance.font.pixelSize.larger
                    color: Colors.colOnLayer0
                    Layout.rightMargin: indicatorsRowLayout.realSpacing

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

                MaterialIcon {
                    //Layout.rightMargin: indicatorsRowLayout.realSpacing
                    text: NetworkService.active ? Icons.getNetworkIcon(NetworkService.active.strength ?? 0) : "signal_wifi_off"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Colors.colOnLayer0 // toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
                }
            }
        }

        ClockWidget {
            showDate: false
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: 5//Appearance.rounding.screenRounding
            Layout.fillWidth: false
        }
    }
}
