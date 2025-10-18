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

    // property list<var> itemsInUserList: SystemTray.items.values.filter(i => (Settings.options.bar.tray.pinnedItems.includes(i.id) && i.status !== Status.Passive))
    property list<var> itemsNotInUserList: SystemTray.items.values.filter(i => (i.status !== Status.Passive))
    property bool invertPins: false//Settings.options.bar.tray.invertPinnedItems
    // property list<var> pinnedItems: invertPins ? itemsNotInUserList : itemsInUserList
    property list<var> unpinnedItems: itemsNotInUserList//invertPins ? itemsInUserList : itemsNotInUserList

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        rowSpacing: 8
        columnSpacing: 15

        RippleButton {
            id: trayOverflowButton
            visible: root.showOverflowMenu
            toggled: sysTrayPopup.active

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
                color: sysTrayPopup.active ? Colors.colOnSecondaryContainer : Colors.colOnLayer2
                rotation: (sysTrayPopup.active ? 180 : 0) //- (90 * root.vertical) + (180 * root.invertSide)
                Behavior on rotation {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }

            onClicked: sysTrayPopup.toggle(this)//root.trayOverflowOpen = !root.trayOverflowOpen

            SysTrayPopup {
                id: sysTrayPopup
                // hoverTarget: trayOverflowButton
                // active: root.trayOverflowOpen
                // popupBackgroundMargin: 300 // This should be plenty... makes sure tooltips don't get cutoff (easily)

            }
        }
    }
}
