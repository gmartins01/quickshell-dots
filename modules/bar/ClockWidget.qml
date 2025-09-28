import qs
import qs.config
import qs.modules.widgets
import qs.services

import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    // property bool borderless: Config.options.bar.borderless
    property bool showDate: false
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.large
            color: Colors.colors.colOnLayer1
            text: TimeService.time
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Colors.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Colors.colors.colOnLayer1
            text: TimeService.date
        }
    }

  
}
