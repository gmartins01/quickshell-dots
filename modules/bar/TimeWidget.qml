import QtQuick
import Quickshell
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 35
    implicitWidth: iconBg.implicitWidth + spacing + textBg.implicitWidth
    radius: 5
    color: "#24273A"

    property int spacing: 6

    Rectangle {
        id: iconBg
        implicitHeight: root.implicitHeight
        implicitWidth:  implicitHeight
        topLeftRadius:    root.radius
        bottomLeftRadius: root.radius
        color: "#B7BCF8"

        anchors {
            left:           parent.left
            leftMargin:     0
            verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.centerIn: parent
            text: ""
            font.family: "Jetbrains Mono NF"
            font.pixelSize: 22
            font.weight:  Font.Bold
            color: "#24273A"
        }
    }

    Rectangle {
        id: textBg
        implicitHeight: root.implicitHeight
        property int padding: 8
        implicitWidth: timeText.paintedWidth + padding*2
        topRightRadius:    root.radius
        bottomRightRadius: root.radius
        color:             root.color

        anchors {
            left:           iconBg.right
            leftMargin:     parent.spacing-2
            verticalCenter: parent.verticalCenter
        }

        Text {
            id: timeText
            anchors.centerIn: parent
            text: Time.time
            font.family: "Jetbrains Mono NF"
            font.pixelSize: 16
            font.weight:  Font.Bold
            color: "#B7BCF8"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
        }
    }
}

