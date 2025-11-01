import qs.config
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray

Scope {
    id: bar
    property bool showBarBackground: true//Config.options.bar.showBackground

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
                implicitHeight: Appearance.sizes.barHeight + Appearance.rounding.screenRounding

                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: Appearance.sizes.baseBarHeight + (Settings.options.bar.cornerStyle === 1 ? Appearance.sizes.hyprlandGapsOut : 0)
                mask: Region {
                    item: barContent
                }
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

                // Round decorators
                Loader {
                    id: roundDecorators
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: barContent.bottom
                        bottom: undefined
                    }
                    height: Appearance.rounding.screenRounding
                    active: true//showBarBackground && Config.options.bar.cornerStyle === 0 // Hug TODO: MEter na config
                    visible: true

                    states: State {
                        name: "bottom"
                        when: Settings.options.bar.bottom
                        AnchorChanges {
                            target: roundDecorators
                            anchors {
                                right: parent.right
                                left: parent.left
                                top: undefined
                                bottom: barContent.bottom
                            }
                        }
                    }

                    sourceComponent: Item {
                        implicitHeight: Appearance.rounding.screenRounding
                        RoundCorner {
                            id: leftCorner
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                            }

                            implicitSize: Appearance.rounding.screenRounding
                            color: bar.showBarBackground ? Colors.colLayer0 : "transparent"

                            corner: RoundCorner.CornerEnum.TopLeft
                            states: State {
                                name: "bottom"
                                when: Settings.options.bar.bottom
                                PropertyChanges {
                                    leftCorner.corner: RoundCorner.CornerEnum.BottomLeft
                                }
                            }
                        }
                        RoundCorner {
                            id: rightCorner
                            anchors {
                                right: parent.right
                                top: !Settings.options.bar.bottom ? parent.top : undefined
                                bottom: Settings.options.bar.bottom ? parent.bottom : undefined
                            }
                            implicitSize: Appearance.rounding.screenRounding
                            color: bar.showBarBackground ? Colors.colLayer0 : "transparent"

                            corner: RoundCorner.CornerEnum.TopRight
                            states: State {
                                name: "bottom"
                                when: Settings.options.bar.bottom
                                PropertyChanges {
                                    rightCorner.corner: RoundCorner.CornerEnum.BottomRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
