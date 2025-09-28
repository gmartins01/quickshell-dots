import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts

Rectangle {
    id: root
    implicitWidth: workspaceRow.implicitWidth + 15
    implicitHeight: 35
    radius: 6
    color: "#24273A"

    property string monitorName: ""

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            const wsList = Hyprland.workspaces.values.filter(ws => ws.monitor && ws.monitor.name === monitorName).sort((a, b) => a.id - b.id).map(ws => ws.id);

            if (!wsList.length)
                return;

            const currentWs = Hyprland.workspaces.values.find(ws => ws.monitor && ws.monitor.name === monitorName && ws.active);
            let idx = currentWs ? wsList.indexOf(currentWs.id) : 0;
            if (idx < 0)
                idx = 0;

            if (wheel.angleDelta.y > 0) {
                idx = (idx + 1) % wsList.length;
            } else if (wheel.angleDelta.y < 0) {
                idx = (idx - 1 + wsList.length) % wsList.length;
            }

            Hyprland.dispatch("workspace " + wsList[idx]);
            wheel.accepted = true;
        }
    }
    Row {
        id: workspaceRow
        spacing: 8

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Repeater {
            model: Hyprland.workspaces.values.filter(ws => ws.monitor && ws.monitor.name === monitorName)

            Item {
                required property var modelData
                property bool hovered: false

                width: 15
                height: 24

                Rectangle {
                    id: background
                    anchors.fill: parent
                    radius: 4

                    color: hovered ? "#494D64" : (modelData.active ? "#B7BCF8" : "#24273A")
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }

                Text {
                    text: modelData.id
                    anchors.centerIn: parent
                    color: modelData.active ? "#181825" : "#B7BCF8"
                    font.pixelSize: 15
                    font.family: "Jetbrains Mono NF"
                    font.bold: true
                }
            }
        }

        Text {
            visible: Hyprland.workspaces.values.filter(ws => ws.monitor && ws.monitor.name === monitorName).length === 0
            text: "No workspaces"
            color: "#ffffff"
            font.pixelSize: 15
            font.bold: true
        }
    }
}
