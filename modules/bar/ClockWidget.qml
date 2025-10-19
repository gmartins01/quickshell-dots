import qs.config
import qs.modules.widgets
import qs.services

import QtQuick
import QtQuick.Layouts
import Quickshell

RippleButton {
    id: root

    property bool showDate: false

    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: rowLayout.implicitHeight + 5 * 2
    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Colors.colLayer1Hover
    colRipple: Colors.colLayer1Active
    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive

    toggled: PanelService.isPanelOpen("calendarPanel")

    onClicked: {
        const panel = PanelService.getPanel("calendarPanel");
        panel?.toggle(this);
    }

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
