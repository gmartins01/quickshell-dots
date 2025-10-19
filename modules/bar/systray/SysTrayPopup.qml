import qs.config
import qs.services
import qs.modules.widgets
import qs.utils

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray

Loader {
    id: root

    property list<var> itemsNotInUserList: SystemTray.items.values.filter(i => (i.status !== Status.Passive))
    property bool invertPins: false//Settings.options.bar.tray.invertPinnedItems
    // property list<var> pinnedItems: invertPins ? itemsNotInUserList : itemsInUserList
    property list<var> unpinnedItems: itemsNotInUserList//invertPins ? itemsInUserList : itemsNotInUserList

    property var activeMenu: null

    property Item hoverTarget
    default property Item contentItem
    property real popupBackgroundMargin: 0

    property var buttonItem: null
    property string buttonName: ""
    property point buttonPosition: Qt.point(0, 0)
    property int buttonWidth: 0
    property int buttonHeight: 0

    active: hoverTarget && hoverTarget.containsMouse

    function toggle(buttonItem, buttonName) {
        if (!active) {
            open(buttonItem, buttonName);
        } else {
            close();
        }
    }

    function open(buttonItem, buttonName) {
        root.buttonItem = buttonItem;
        root.buttonName = buttonName || "";

        setPosition();

        // backgroundClickEnabled = true;
        active = true;
    // root.opened();
    }

    function close() {
        // scaleValue = originalScale;
        // opacityValue = originalOpacity;
        // root.closed();
        active = false;
    // backgroundClickEnabled = true;
    }

    function setPosition() {
        var itemPos = buttonItem.mapToItem(null, 0, 0);
        buttonPosition = Qt.point(itemPos.x, itemPos.y);
        buttonWidth = buttonItem.width;
        buttonHeight = buttonItem.height;
    }

    function setExtraWindowAndGrabFocus(window) {
        root.activeMenu = window;
    }

    sourceComponent: Component {

        PanelWindow {
            id: panelWindow

            color: "transparent"
            visible: true

            // anchors.left: false//!Settings.options.bar.vertical || (Settings.options.bar.vertical && !Settings.options.bar.position === "bottom")
            // anchors.right: true//Settings.options.bar.vertical && Settings.options.bar.position === "bottom"
            // anchors.top: true//Settings.options.bar.vertical || (!Settings.options.bar.vertical && !Settings.options.bar.position === "bottom")
            // anchors.bottom: false//!Settings.options.bar.vertical && Settings.options.bar.position === "bottom"

            // implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
            // implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
            //
            // mask: Region {
            //     item: popupBackground
            // }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:popup"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // margins {
            //     left: {
            //         if (!Settings.options.bar.vertical)
            //             return root.QsWindow?.mapFromItem(root.hoverTarget, (root.hoverTarget.width - popupBackground.implicitWidth) / 2, 0).x;
            //         return Appearance.sizes.verticalBarWidth;
            //     }
            //     top: {
            //         if (!Settings.options.bar.vertical)
            //             return Appearance.sizes.barHeight;
            //         return root.QsWindow?.mapFromItem(root.hoverTarget, (root.hoverTarget.height - popupBackground.implicitHeight) / 2, 0).y;
            //     }
            //     right: Appearance.sizes.verticalBarWidth
            //     bottom: Appearance.sizes.barHeight
            // }

            StyledRectangularShadow {
                target: popupBackground
            }

            anchors.top: true
            anchors.left: true
            anchors.right: true
            anchors.bottom: true

            // Close any panel with Esc without requiring focus
            Shortcut {
                sequences: ["Escape"]
                enabled: root.active
                onActivated: root.close()
                context: Qt.WindowShortcut
            }

            // Clicking outside of the rectangle to close
            TapHandler {
                onTapped: eventPoint => {
                    if (!popupBackground.contains(eventPoint.position))
                        root.toggle();
                    else
                        eventPoint.accepted = true;
                }
            }

            Rectangle {
                id: popupBackground
                readonly property real margin: 10
                // anchors {
                //     // fill: parent
                //     leftMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.left)
                //     rightMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.right)
                //     topMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.top)
                //     bottomMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.bottom)
                // }
                implicitWidth: trayOverflowLayout.implicitWidth + margin * 2
                implicitHeight: trayOverflowLayout.implicitHeight + margin * 2
                color: ColorUtils.applyAlpha(Colors.colors.colSurfaceContainer, 1 - Appearance.backgroundTransparency)
                radius: Appearance.rounding.small
                x: calculatedX
                y: calculatedY
                // children: [root.contentItem]

                border.width: 1
                border.color: Colors.colors.colLayer0Border

                GridLayout {
                    id: trayOverflowLayout
                    anchors.centerIn: parent
                    columns: Math.ceil(Math.sqrt(root.unpinnedItems.length))
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: root.unpinnedItems

                        delegate: SysTrayItem {
                            required property SystemTrayItem modelData
                            item: modelData
                            Layout.fillHeight: true//!root.vertical
                            Layout.fillWidth: false//root.vertical
                            popupX: popupBackground.calculatedX
                            popupY: popupBackground.calculatedY
                            onMenuClosed: root.close()
                            // onMenuOpened: qsWindow => root.setExtraWindowAndGrabFocus(qsWindow)
                        }
                    }
                }

                property real marginTop: Appearance.sizes.barHeight + 10
                property real marginLeft: 5
                property real marginBottom: 5
                property real marginRight: 5

                property int calculatedX: {
                    var targetX = root.buttonPosition.x + (root.buttonWidth / 2) - (popupBackground.width / 2);
                    var maxX = panelWindow.width - popupBackground.width - marginRight;
                    var minX = marginLeft;

                    return Math.round(Math.max(minX, Math.min(targetX, maxX)));
                }

                property int calculatedY: {
                    var targetY = root.buttonPosition.y + (root.buttonHeight / 2) - (popupBackground.height / 2);
                    // Keep panel within screen bounds
                    var maxY = panelWindow.height - popupBackground.height - marginBottom;
                    var minY = marginTop;
                    return Math.round(Math.max(minY, Math.min(targetY, maxY)));
                }
                // // Prevent closing when clicking in the panel bg
                // MouseArea {
                //     anchors.fill: parent
                // }
            }
        }
    }
}
