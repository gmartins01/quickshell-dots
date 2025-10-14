import qs.config
import qs.services
import qs.modules.widgets

import QtQuick

RippleButton {
    id: root

    property bool showPing: false
    property var popupTarget: null
    property var parentScreen: null

    property real buttonPadding: 5
    implicitWidth: icon.width + buttonPadding * 2
    implicitHeight: icon.height + buttonPadding * 2
    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Colors.colors.colLayer1Hover
    colRipple: Colors.colors.colLayer1Active
    colBackgroundToggled: Colors.colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colors.colSecondaryContainerHover
    colRippleToggled: Colors.colors.colSecondaryContainerActive

    signal notifIconClicked

    onClicked: {
        console.log("CLICCCC");
        const panel = PanelService.getPanel("notificationHistoryPanel");
        panel?.toggle(this);
    }
    // onPressed: {
    //     console.log("Clicked");
    //     if (popupTarget && popupTarget.setTriggerPosition) {
    //         const globalPos = mapToGlobal(0, 0);
    //         const currentScreen = parentScreen || Screen;
    //         const pos = Appearance.getPopupTriggerPosition(globalPos, currentScreen,  width);
    //         popupTarget.setTriggerPosition(pos.x, pos.y, pos.width, section, currentScreen);
    //     }
    //     root.notifIconClicked();
    // }

    MaterialIcon {
        id: icon
        anchors.centerIn: parent
        iconSize: Appearance.font.pixelSize.larger
        text: "Notifications"
        horizontalAlignment: Text.AlignHCenter
        color: Colors.colors.colOnLayer2
    }
}
