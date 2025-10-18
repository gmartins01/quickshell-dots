import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Item {
    id: root
    implicitWidth: gridLayout.implicitWidth
    implicitHeight: gridLayout.implicitHeight
    property bool vertical: false
    property bool invertSide: false
    property bool trayOverflowOpen: false
    property bool showSeparator: true
    property bool showOverflowMenu: true
    property var activeMenu: null

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        rowSpacing: 8
        columnSpacing: 15
    }

    RippleButton {
        id: trayOverflowButton
        visible: root.showOverflowMenu
        toggled: root.trayOverflowOpen
        property bool containsMouse: hovered

        Layout.fillHeight: true
        Layout.fillWidth: false
        background.implicitWidth: 24
        background.implicitHeight: 24
        background.anchors.centerIn: this
        colBackgroundToggled: Colors.colSecondaryContainer
        colBackgroundToggledHover: Colors.colSecondaryContainerHover
        colRippleToggled: Colors.colSecondaryContainerActive

        contentItem: MaterialIcon {
            anchors.centerIn: parent
            iconSize: Appearance.font.pixelSize.larger
            text: "expand_more"
            horizontalAlignment: Text.AlignHCenter
            color: root.trayOverflowOpen ? Colors.colOnSecondaryContainer : Colors.colOnLayer2
            rotation: (root.trayOverflowOpen ? 180 : 0) //- (90 * root.vertical) + (180 * root.invertSide)
            Behavior on rotation {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
        }

        onClicked: {
            const panel = PanelService.getPanel("systrayPopup");
            panel?.toggle(this);
        }

        SystrayPopupTest {
            id: systrayPopupTest
            objectName: "systrayPopupTest"
        }
    }
}
