import qs.config
import qs.services
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray

StyledPanel {
    id: root

    preferredWidth: systrayPopup.implicitWidth
    preferredHeight: systrayPopup.implicitHeight

    panelBackgroundColor: Colors.colLayer1
    panelKeyboardFocus: true
    property list<var> itemsNotInUserList: SystemTray.items.values.filter(i => (i.status !== Status.Passive))
    property list<var> unpinnedItems: itemsNotInUserList

    panelContent: Item {
        id: systrayPopup
        anchors.fill: parent
        anchors.margins: 5
        implicitWidth: trayOverflowLayout.implicitWidth
        implicitHeight: trayOverflowLayout.implicitHeight

        GridLayout {
            id: trayOverflowLayout
            anchors.centerIn: parent
            columns: 3//Math.ceil(Math.sqrt(root.unpinnedItems.length))
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: root.unpinnedItems

                onItemAdded: Qt.callLater(() => {
                    root.preferredWidth = systrayPopup.implicitWidth;
                    root.preferredHeight = systrayPopup.implicitHeight;
                })

                delegate: SysTrayItem {
                    required property SystemTrayItem modelData
                    item: modelData
                    Layout.fillHeight: true
                    Layout.fillWidth: false
                    // onMenuClosed: root.releaseFocus()
                    // onMenuOpened: qsWindow => root.setExtraWindowAndGrabFocus(qsWindow)
                }
            }
        }
    }
}
