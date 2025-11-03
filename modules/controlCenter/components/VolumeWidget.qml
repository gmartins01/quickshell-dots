import qs.config
import qs.services
import qs.utils
import qs.modules.widgets

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    property bool hasVolumeSliderInCC: false

    implicitHeight: headerRow.height + (!hasVolumeSliderInCC ? volumeSlider.height : 0) + audioContent.height + Appearance.margins.normal
    radius: Appearance.rounding.normal
    color: Colors.colSurfaceContainerHigh
    // border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    // border.width: 0

    Row {
        id: headerRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.margins.normal
        anchors.rightMargin: Appearance.margins.normal
        anchors.topMargin: Appearance.margins.sall
        height: 40

        StyledText {
            id: headerText
            text: "Audio Devices"
            // font.pixelSize: Appearance.font.size.large
            color: Colors.colOnLayer0
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        id: volumeSlider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerRow.bottom
        anchors.leftMargin: Appearance.margins.normal
        anchors.rightMargin: Appearance.margins.normal
        anchors.topMargin: Appearance.margins.smaller
        height: 35
        spacing: 0
        visible: !hasVolumeSliderInCC

        Rectangle {
            width: Appearance.font.pixelSize.iconSize + Appearance.margins.small * 2
            height: Appearance.font.pixelSize.iconSize + Appearance.margins.small * 2
            anchors.verticalCenter: parent.verticalCenter
            radius: (Appearance.font.pixelSize.iconSize + Appearance.margins.small * 2) / 2
            color: iconArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

            MouseArea {
                id: iconArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = !AudioService.sink.audio.muted;
                    }
                }
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
                iconSize: Appearance.font.pixelSize.iconSize
                color: Colors.colPrimary
            }
        }

        StyledSlider {
            readonly property real actualVolumePercent: AudioService.sink && AudioService.sink.audio ? Math.round(AudioService.sink.audio.volume * 100) : 0

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (Appearance.font.pixelSize.iconSize + Appearance.margins.small * 2)
            enabled: AudioService.sink && AudioService.sink.audio
            minimum: 0
            maximum: 100
            value: AudioService.sink && AudioService.sink.audio ? Math.min(100, Math.round(AudioService.sink.audio.volume * 100)) : 0
            showValue: true
            unit: "%"
            valueOverride: actualVolumePercent
            thumbOutlineColor: Colors.colOnLayer1//Theme.surfaceVariant

            onSliderValueChanged: function (newValue) {
                if (AudioService.sink && AudioService.sink.audio) {
                    AudioService.sink.audio.volume = newValue / 100;
                    if (newValue > 0 && AudioService.sink.audio.muted) {
                        AudioService.sink.audio.muted = false;
                    }
                    AudioService.volumeChanged();
                }
            }
        }
    }

    StyledFlickable {
        id: audioContent
        anchors.top: volumeSlider.visible ? volumeSlider.bottom : headerRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.margins.normal
        anchors.topMargin: volumeSlider.visible ? Appearance.margins.small : Appearance.margins.normal

        implicitHeight: audioColumn.implicitHeight

        contentHeight: audioColumn.implicitHeight        // contentHeight: audioColumn.height
        clip: true

        Column {
            id: audioColumn
            width: parent.width
            spacing: Appearance.margins.small

            Repeater {
                model: Pipewire.nodes.values.filter(node => {
                    return node.audio && node.isSink && !node.isStream;
                })

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: parent.width
                    height: 50
                    radius: Appearance.rounding.normal//Theme.cornerRadius
                    color: deviceMouseArea.containsMouse ? Colors.colPrimary : Colors.colSurfaceContainerHighest
                    // border.color: modelData === AudioService.sink ? Colors.colPrimary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                    // border.width: 0

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Appearance.margins.normal
                        spacing: Appearance.margins.small

                        MaterialIcon {
                            text: {
                                if (modelData.name.includes("bluez"))
                                    return "headset";
                                else if (modelData.name.includes("hdmi"))
                                    return "tv";
                                else if (modelData.name.includes("usb"))
                                    return "headset";
                                else
                                    return "speaker";
                            }
                            iconSize: Appearance.font.pixelSize.iconSize - 4
                            color: modelData === AudioService.sink ? Colors.colPrimary : Colors.colOnLayer0
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - Appearance.font.pixelSize.iconSize - Appearance.margins.normal

                            StyledText {
                                text: AudioService.displayName(modelData)
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Colors.colOnLayer0 //Theme.surfaceText
                                font.weight: modelData === AudioService.sink ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                                width: parent.width
                                wrapMode: Text.NoWrap
                            }

                            StyledText {
                                text: modelData === AudioService.sink ? "Active" : "Available"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Colors.colOnLayer0// Theme.surfaceVariantText
                                elide: Text.ElideRight
                                width: parent.width
                                wrapMode: Text.NoWrap
                            }
                        }
                    }

                    MouseArea {
                        id: deviceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData) {
                                Pipewire.preferredDefaultAudioSink = modelData;
                            }
                        }
                    }
                }
            }
        }
    }
}
