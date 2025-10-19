import qs.config
import qs.services
import qs.utils
import qs.modules.widgets

import QtQuick

OSD {
    id: root

    osdWidth: Math.min(260, Screen.width - 20)//Theme.spacingM * 2)
    autoHideInterval: 2000
    enableMouseInteraction: true

    Connections {
        target: AudioService.sink && AudioService.sink.audio ? AudioService.sink.audio : null

        function onVolumeChanged() {
            if (!AudioService.suppressOSD) {
                root.show();
            }
        }

        function onMutedChanged() {
            if (!AudioService.suppressOSD) {
                root.show();
            }
        }
    }

    Connections {
        target: AudioService

        function onSinkChanged() {
            if (root.shouldBeVisible) {
                root.show();
            }
        }
    }

    content: Item {
        anchors.fill: parent

        Item {
            property int gap: 7//Theme.spacingS

            anchors.centerIn: parent
            width: parent.width - 14//Theme.spacingS * 2
            height: 40

            Rectangle {
                width: 24//Theme.iconSize
                height: 24//Theme.iconSize
                radius: 12//Theme.iconSize / 2
                color: "transparent"
                x: parent.gap
                anchors.verticalCenter: parent.verticalCenter

                MaterialIcon {
                    anchors.centerIn: parent
                    text: Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
                    iconSize: 24//Theme.iconSize
                    color: muteButton.containsMouse ? Colors.colPrimary : Colors.colOnLayer0
                }

                MouseArea {
                    id: muteButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        AudioService.toggleMute();
                    }
                    onContainsMouseChanged: {
                        setChildHovered(containsMouse || volumeSlider.containsMouse);
                    }
                }
            }

            StyledSlider {
                id: volumeSlider

                readonly property real actualVolumePercent: AudioService.sink && AudioService.sink.audio ? Math.round(AudioService.sink.audio.volume * 100) : 0
                readonly property real displayPercent: actualVolumePercent

                width: parent.width - 24 - parent.gap * 3
                height: 40
                x: parent.gap * 2 + 24
                anchors.verticalCenter: parent.verticalCenter
                minimum: 0
                maximum: 100
                enabled: AudioService.sink && AudioService.sink.audio
                showValue: true
                unit: "%"
                thumbOutlineColor: Colors.colSurfaceContainer
                valueOverride: displayPercent
                alwaysShowValue: false//SettingsData.osdAlwaysShowValue

                Component.onCompleted: {
                    if (AudioService.sink && AudioService.sink.audio) {
                        value = Math.min(100, Math.round(AudioService.sink.audio.volume * 100));
                    }
                }

                onSliderValueChanged: newValue => {
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.suppressOSD = true;
                        AudioService.sink.audio.volume = newValue / 100;
                        AudioService.suppressOSD = false;
                        resetHideTimer();
                    }
                }

                onContainsMouseChanged: {
                    setChildHovered(containsMouse || muteButton.containsMouse);
                }

                Connections {
                    target: AudioService.sink && AudioService.sink.audio ? AudioService.sink.audio : null

                    function onVolumeChanged() {
                        if (volumeSlider && !volumeSlider.pressed) {
                            volumeSlider.value = Math.min(100, Math.round(AudioService.sink.audio.volume * 100));
                        }
                    }
                }
            }
        }
    }

    onOsdShown: {
        if (AudioService.sink && AudioService.sink.audio && contentLoader.item) {
            const slider = contentLoader.item.children[0].children[1];
            if (slider) {
                slider.value = Math.min(100, Math.round(AudioService.sink.audio.volume * 100));
            }
        }
    }
}
