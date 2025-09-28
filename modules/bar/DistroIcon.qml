import qs.services

import qs.config
import qs.modules.widgets

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls

RippleButton {
    id: root

    property bool showPing: false

    property real buttonPadding: 5
    implicitWidth: distroIcon.width + buttonPadding * 2
    implicitHeight: distroIcon.height + buttonPadding * 2
    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Colors.colors.colLayer1Hover
    colRipple: Colors.colors.colLayer1Active
    colBackgroundToggled: Colors.colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colors.colSecondaryContainerHover
    colRippleToggled: Colors.colors.colSecondaryContainerActive

    onPressed: {
        WallpaperService.changeWallpaper("/home/gmartins/Pictures/Wallpapers/qk81y2vbscz71.jpg", undefined);
    }

    CustomIcon {
        id: distroIcon
        anchors.centerIn: parent
        width: 19.5
        height: 19.5
        source: "nixos-symbolic"//Config.options.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : `${Config.options.bar.topLeftIcon}-symbolic`
        colorize: true
        color: Colors.colors.colOnLayer0

        // Rectangle {
        //     opacity: root.showPing ? 1 : 0
        //     visible: opacity > 0
        //     anchors {
        //         bottom: parent.bottom
        //         right: parent.right
        //         bottomMargin: -2
        //         rightMargin: -2
        //     }
        //     implicitWidth: 8
        //     implicitHeight: 8
        //     radius: Appearance.rounding.full
        //     color: Colors.m3colors.m3tertiary
        //
        //     Behavior on opacity {
        //         animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        //     }
        // }
    }
}
