import qs.config
import qs.services
import qs.utils
import qs.modules.widgets

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Row {
    id: root

    property var defaultSink: AudioService.sink
    property color sliderTrackColor: "transparent"

    height: 20
    spacing: 0

    Rectangle {
        width: 24 + 7 * 2
        height: 24 + 7 * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: (24 + 7 * 2) / 2
        color: iconArea.containsMouse ? Colors.colOnPrimary : "transparent"

        MouseArea {
            id: iconArea
            anchors.fill: parent
            visible: defaultSink !== null
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (defaultSink) {
                    AudioService.suppressOSD = true;
                    defaultSink.audio.muted = !defaultSink.audio.muted;
                    AudioService.suppressOSD = false;
                }
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
            iconSize: 24//Theme.iconSize
            color: Colors.colPrimary
        }
        // DankIcon {
        //     anchors.centerIn: parent
        //     name: {
        //         if (!defaultSink)
        //             return "volume_off";
        //
        //         let volume = defaultSink.audio.volume;
        //         let muted = defaultSink.audio.muted;
        //
        //         if (muted || volume === 0.0)
        //             return "volume_off";
        //         if (volume <= 0.33)
        //             return "volume_down";
        //         if (volume <= 0.66)
        //             return "volume_up";
        //         return "volume_up";
        //     }
        //     size: Theme.iconSize
        //     color: defaultSink && !defaultSink.audio.muted && defaultSink.audio.volume > 0 ? Theme.primary : Theme.surfaceText
        // }
    }

    StyledSlider {
        id: volumeSlider

        readonly property real actualVolumePercent: AudioService.sink && AudioService.sink.audio ? Math.round(AudioService.sink.audio.volume * 100) : 0
        readonly property real displayPercent: actualVolumePercent

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width -(24 + 7 * 2)
        height: 40
        minimum: 0
        maximum: 100
        enabled: AudioService.sink && AudioService.sink.audio
        showValue: true
        unit: "%"
        thumbOutlineColor: Colors.colSurfaceContainer
        valueOverride: displayPercent
        alwaysShowValue: false
        onSliderValueChanged: newValue => {
            if (AudioService.sink && AudioService.sink.audio) {
                AudioService.sink.audio.volume = newValue / 100;
            }
        }

        Component.onCompleted: {
            if (AudioService.sink && AudioService.sink.audio) {
                value = Math.min(100, Math.round(AudioService.sink.audio.volume * 100));
            }
        }
    }

    // DankSlider {
    //     readonly property real actualVolumePercent: defaultSink ? Math.round(defaultSink.audio.volume * 100) : 0
    //
    //     anchors.verticalCenter: parent.verticalCenter
    //     width: parent.width - (Theme.iconSize + Theme.spacingS * 2)
    //     enabled: defaultSink !== null
    //     minimum: 0
    //     maximum: 100
    //     value: defaultSink ? Math.min(100, Math.round(defaultSink.audio.volume * 100)) : 0
    //     showValue: true
    //     unit: "%"
    //     valueOverride: actualVolumePercent
    //     thumbOutlineColor: Theme.surfaceContainer
    //     trackColor: root.sliderTrackColor.a > 0 ? root.sliderTrackColor : Theme.surfaceContainerHigh
    //     onSliderValueChanged: function (newValue) {
    //         if (defaultSink) {
    //             defaultSink.audio.volume = newValue / 100.0;
    //             if (newValue > 0 && defaultSink.audio.muted) {
    //                 defaultSink.audio.muted = false;
    //             }
    //         }
    //     }
    // }
}
