import qs.config

import QtQuick
import QtQuick.Effects

Item {
    id: slider

    property int value: 50
    property int minimum: 0
    property int maximum: 100
    property string leftIcon: ""
    property string rightIcon: ""
    property bool enabled: true
    property string unit: "%"
    property bool showValue: true
    property bool isDragging: false
    property bool wheelEnabled: true
    property real valueOverride: -1
    property bool alwaysShowValue: false
    readonly property bool containsMouse: sliderMouseArea.containsMouse

    property color thumbOutlineColor: Colors.colSurfaceContainer
    property color trackColor: Colors?.m3colors.m3secondaryContainer//enabled ? Theme.outline : Theme.outline

    signal sliderValueChanged(int newValue)
    signal sliderDragFinished(int finalValue)

    height: 48

    function updateValueFromPosition(x) {
        let ratio = Math.max(0, Math.min(1, (x - sliderHandle.width / 2) / (sliderTrack.width - sliderHandle.width)));
        let newValue = Math.round(minimum + ratio * (maximum - minimum));
        if (newValue !== value) {
            value = newValue;
            sliderValueChanged(newValue);
        }
    }

    Row {
        anchors.centerIn: parent
        width: parent.width
        spacing: 10//Theme.spacingM

        // MaterialIcon {
        //     text: ""
        //     iconSize: 24//Theme.iconSize
        //     color: "#FFF"//slider.enabled ? Theme.surfaceText : Theme.onSurface_38
        //     anchors.verticalCenter: parent.verticalCenter
        //     visible: slider.leftIcon.length > 0
        // }

        StyledRect {
            id: sliderTrack

            property int leftIconWidth: slider.leftIcon.length > 0 ? Theme.iconSize : 0
            property int rightIconWidth: slider.rightIcon.length > 0 ? Theme.iconSize : 0

            width: parent.width - (leftIconWidth + rightIconWidth + (slider.leftIcon.length > 0 ? Theme.spacingM : 0) + (slider.rightIcon.length > 0 ? Theme.spacingM : 0))
            height: 12
            radius: 10//Theme.cornerRadius
            color: slider.trackColor
            anchors.verticalCenter: parent.verticalCenter
            clip: false

            StyledRect {
                id: sliderFill
                height: parent.height
                radius: 10//Theme.cornerRadius
                width: {
                    const ratio = (slider.value - slider.minimum) / (slider.maximum - slider.minimum);
                    const travel = sliderTrack.width - sliderHandle.width;
                    const center = (travel * ratio) + sliderHandle.width / 2;
                    return Math.max(0, Math.min(sliderTrack.width, center));
                }
                color: slider.enabled ? Colors.colPrimary : Colors.colOnLayer3
            }

            StyledRect {
                id: sliderHandle

                property bool active: sliderMouseArea.containsMouse || sliderMouseArea.pressed || slider.isDragging

                width: 8
                height: 24
                radius: 10//Theme.cornerRadius
                x: {
                    const ratio = (slider.value - slider.minimum) / (slider.maximum - slider.minimum);
                    const travel = sliderTrack.width - width;
                    return Math.max(0, Math.min(travel, travel * ratio));
                }
                anchors.verticalCenter: parent.verticalCenter
                color: slider.enabled ? Colors.colPrimary : Colors?.m3colors.m3secondaryContainer
                border.width: 3
                border.color: slider.thumbOutlineColor

                StyledRect {
                    anchors.fill: parent
                    radius: 10//Theme.cornerRadius
                    color: Colors.colOnPrimary
                    opacity: slider.enabled ? (sliderMouseArea.pressed ? 0.16 : (sliderMouseArea.containsMouse ? 0.08 : 0)) : 0
                    visible: opacity > 0
                }

                StyledRect {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Colors.colPrimary
                    opacity: slider.enabled && slider.focus ? 0.3 : 0
                    visible: opacity > 0
                }

                Rectangle {
                    id: ripple
                    anchors.centerIn: parent
                    width: 0
                    height: 0
                    radius: width / 2
                    color: Colors.colOnPrimary
                    opacity: 0

                    function start() {
                        opacity = 0.16;
                        width = 0;
                        height = 0;
                        rippleAnimation.start();
                    }

                    SequentialAnimation {
                        id: rippleAnimation
                        NumberAnimation {
                            target: ripple
                            properties: "width,height"
                            to: 28
                            duration: 180
                        }
                        NumberAnimation {
                            target: ripple
                            property: "opacity"
                            to: 0
                            duration: 150
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onPressedChanged: {
                        if (pressed && slider.enabled) {
                            ripple.start();
                        }
                    }
                }

                scale: active ? 1.05 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 200//Theme.shortDuration
                        easing.type: Easing.OutCubic//Theme.standardEasing
                    }
                }
            }

            Item {
                id: sliderContainer

                anchors.fill: parent

                MouseArea {
                    id: sliderMouseArea

                    property bool isDragging: false

                    anchors.fill: parent
                    anchors.topMargin: -10
                    anchors.bottomMargin: -10
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: slider.enabled
                    preventStealing: true
                    acceptedButtons: Qt.LeftButton
                    onWheel: wheelEvent => {
                        if (!slider.wheelEnabled) {
                            wheelEvent.accepted = false;
                            return;
                        }
                        let step = Math.max(0.5, (maximum - minimum) / 100);
                        let newValue = wheelEvent.angleDelta.y > 0 ? Math.min(maximum, value + step) : Math.max(minimum, value - step);
                        newValue = Math.round(newValue);
                        if (newValue !== value) {
                            value = newValue;
                            sliderValueChanged(newValue);
                        }
                        wheelEvent.accepted = true;
                    }
                    onPressed: mouse => {
                        if (slider.enabled) {
                            slider.isDragging = true;
                            sliderMouseArea.isDragging = true;
                            updateValueFromPosition(mouse.x);
                        }
                    }
                    onReleased: {
                        if (slider.enabled) {
                            slider.isDragging = false;
                            sliderMouseArea.isDragging = false;
                            slider.sliderDragFinished(slider.value);
                        }
                    }
                    onPositionChanged: mouse => {
                        if (pressed && slider.isDragging && slider.enabled) {
                            updateValueFromPosition(mouse.x);
                        }
                    }
                    onClicked: mouse => {
                        if (slider.enabled && !slider.isDragging) {
                            updateValueFromPosition(mouse.x);
                        }
                    }
                }
            }

            StyledRect {
                id: valueTooltip

                width: tooltipText.contentWidth + 7 * 2
                height: tooltipText.contentHeight + 5 * 2
                radius: 10//Theme.cornerRadius
                color: Colors.colLayer0
                border.color: Colors.colLayer0Border
                border.width: 1
                anchors.bottom: parent.top
                anchors.bottomMargin: 10//Theme.spacingM
                x: Math.max(0, Math.min(parent.width - width, sliderHandle.x + sliderHandle.width / 2 - width / 2))
                visible: slider.alwaysShowValue ? slider.showValue : ((sliderMouseArea.containsMouse && slider.showValue) || (slider.isDragging && slider.showValue))
                opacity: visible ? 1 : 0

                StyledText {
                    id: tooltipText

                    text: (slider.valueOverride >= 0 ? Math.round(slider.valueOverride) : slider.value) + slider.unit
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Colors.colOnLayer0
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    font.hintingPreference: Font.PreferFullHinting
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200//Theme.shortDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // MaterialIcon {
        //     text: ""
        //     iconSize: 24//Theme.iconSize
        //     color: "red"//slider.enabled ? Theme.surfaceText : Theme.onSurface_38
        //     anchors.verticalCenter: parent.verticalCenter
        //     visible: slider.rightIcon.length > 0
        // }
    }
}
