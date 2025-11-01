import qs.config
import qs.utils
import qs.modules.widgets

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root

    property Item hoverTarget
    default property Item contentItem
    property real popupBackgroundMargin: 0

    active: hoverTarget && hoverTarget.containsMouse

    component: PanelWindow {
        id: popupWindow
        color: "transparent"

        anchors.left: false//!Settings.options.bar.vertical || (Settings.options.bar.vertical && !Settings.options.bar.position === "bottom")
        anchors.right: true//Settings.options.bar.vertical && Settings.options.bar.position === "bottom"
        anchors.top: true//Settings.options.bar.vertical || (!Settings.options.bar.vertical && !Settings.options.bar.position === "bottom")
        anchors.bottom: false//!Settings.options.bar.vertical && Settings.options.bar.position === "bottom"

        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin

        mask: Region {
            item: popupBackground
        }

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        margins {
            left: {
                if (!Settings.options.bar.vertical)
                    return root.QsWindow?.mapFromItem(root.hoverTarget, (root.hoverTarget.width - popupBackground.implicitWidth) / 2, 0).x;
                return Appearance.sizes.verticalBarWidth;
            }
            top: {
                if (!Settings.options.bar.vertical)
                    return Appearance.sizes.barHeight;
                return root.QsWindow?.mapFromItem(root.hoverTarget, (root.hoverTarget.height - popupBackground.implicitHeight) / 2, 0).y;
            }
            right: Appearance.sizes.verticalBarWidth
            bottom: Appearance.sizes.barHeight
        }
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay

        StyledRectangularShadow {
            target: popupBackground
        }

        Rectangle {
            id: popupBackground
            readonly property real margin: 10
            anchors {
                fill: parent
                leftMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.left)
                rightMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.right)
                topMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.top)
                bottomMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.bottom)
            }
            implicitWidth: root.contentItem.implicitWidth + margin * 2
            implicitHeight: root.contentItem.implicitHeight + margin * 2
            color: ColorUtils.applyAlpha(Colors.colors.colSurfaceContainer, 1 - Appearance.backgroundTransparency)
            radius: Appearance.rounding.XXS
            children: [root.contentItem]

            border.width: 1
            border.color: Colors.colors.colLayer0Border
        }
    }
}
