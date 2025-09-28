import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray


Item {
    id: root

    readonly property Repeater items: items

    clip: true
    visible: width > 0 && height > 0 // To avoid warnings about being visible with no size

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Column {
        id: layout

        spacing: 5



        Repeater {
            id: items

            model: SystemTray.items

            TrayItem {}
        }
    }

}
