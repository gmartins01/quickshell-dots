import qs.modules.common
import qs.config

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray

Scope {
    id: bar

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: true

            required property ShellScreen modelData

            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData

                WlrLayershell.namespace: "quickshell:bar"
                implicitHeight: Appearance.sizes.barHeight

                color: "transparent"

                anchors {
                    top: !Settings.options.bar.bottom
                    left: true
                    right: true
                    bottom: Settings.options.bar.bottom
                }

                BarContent {
                    id: barContent

                    screen: barLoader.modelData

                    implicitHeight: Appearance.sizes.barHeight

                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.top
                        bottom: undefined
                        topMargin: 0
                        bottomMargin: 0
                        rightMargin: 0
                    }
                }
            }
        }
    }
}
