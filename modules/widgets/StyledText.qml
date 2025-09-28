import qs.config

import QtQuick

Text {
    id: root

    font {
        hintingPreference: Font.PreferFullHinting
        family: Appearance?.font.family.main ?? "sans-serif"
        pixelSize: Appearance?.font.pixelSize.small ?? 15
    }
    // font.weight: Style.fontWeightMedium
    // font.hintingPreference: Font.PreferNoHinting
    font.kerning: true
    color: Colors.m3colors.m3onSurface
    renderType: Text.QtRendering
    verticalAlignment: Text.AlignVCenter
}
