import qs.config
import qs.utils
import qs.modules.widgets

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root
    required property SystemTrayItem item
    property bool targetMenuOpen: false

    property int popupX: 0
    property int popupY: 0

    signal menuOpened(qsWindow: var)
    signal menuClosed

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 20
    implicitHeight: 20
    onPressed: event => {
        switch (event.button) {
        case Qt.LeftButton:
            item.activate();
            break;
        case Qt.RightButton:
            if (item.hasMenu)
                menu.open();
            break;
        }
        event.accepted = true;
    }
    onEntered: {
        tooltip.text = item.tooltipTitle.length > 0 ? item.tooltipTitle : (item.title.length > 0 ? item.title : item.id);
        if (item.tooltipDescription.length > 0)
            tooltip.text += " • " + item.tooltipDescription;
        if (Settings.options.bar.tray.showItemId)
            tooltip.text += "\n[" + item.id + "]";
    }

    Loader {
        id: menu
        function open() {
            menu.active = true;
        }
        active: false
        sourceComponent: SysTrayMenu {
            Component.onCompleted: this.open()
            trayItemMenuHandle: root.item.menu
            anchor {
                window: root.QsWindow.window
                rect.x: root.popupX + root.x + (root.width/2) - (this.width / 2) 
                // rect.y: root.y + (Settings.options.bar.vertical ? QsWindow.window?.height : 0)
                rect.y: root.popupY + root.y - (root.height / 2)
                rect.height: root.height
                rect.width: root.width
                edges: Settings.options.bar.bottom ? (Edges.Top | Edges.Left) : (Edges.Bottom | Edges.Right) //TODO: VER ISTO
                gravity: Settings.options.bar.bottom ? (Edges.Top | Edges.Left) : (Edges.Bottom | Edges.Right)
            }
            onMenuOpened: window => root.menuOpened(window)
            onMenuClosed: {
                console.log("FECHADO");
                root.menuClosed();
                menu.active = false;
            }
        }
    }

    IconImage {
        id: trayIcon
        visible: !Settings.options.bar.tray.monochromeIcons
        source: root.item.icon
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
    }

    Loader {
        active: Settings.options.bar.tray.monochromeIcons
        anchors.fill: trayIcon
        sourceComponent: Item {
            Desaturate {
                id: desaturatedIcon
                visible: false // There's already color overlay
                anchors.fill: parent
                source: trayIcon
                desaturation: 0.8 // 1.0 means fully grayscale
            }
            ColorOverlay {
                anchors.fill: desaturatedIcon
                source: desaturatedIcon
                color: ColorUtils.transparentize(Colors.colors.colOnLayer0, 0.9)
            }
        }
    }

    PopupToolTip {
        id: tooltip
        extraVisibleCondition: root.containsMouse
        alternativeVisibleCondition: extraVisibleCondition //TODO: ver linha de baixo
        anchorEdges: Settings.options.bar.position === "top" ? Edges.Bottom : Edges.Top//(!Settings.options.bar.bottom && !Config.options.bar.vertical) ? Edges.Bottom : Edges.Top
    }
}
