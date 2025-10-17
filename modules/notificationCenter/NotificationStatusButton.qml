import qs.config
import qs.modules.widgets

import QtQuick
import QtQuick.Layouts

GroupButton {
    id: button
    property string buttonText: ""
    property string buttonIcon: ""

    baseWidth: content.implicitWidth + 10 * 2
    baseHeight: 30

    buttonRadius: baseHeight / 2
    buttonRadiusPressed: Appearance.rounding.small
    colBackground: Colors.colLayer2
    colBackgroundHover: Colors.colLayer2Hover
    colBackgroundActive: Colors.colLayer2Active
    property color colText: toggled ? Colors.m3colors.m3onPrimary : Colors.colOnLayer1

    contentItem: Item {
        id: content
        anchors.fill: parent
        implicitWidth: contentRowLayout.implicitWidth
        implicitHeight: contentRowLayout.implicitHeight
        RowLayout {
            id: contentRowLayout
            anchors.centerIn: parent
            spacing: 5
            MaterialIcon {
                text: buttonIcon
                iconSize: Appearance.font.pixelSize.large
                color: button.colText
            }
            StyledText {
                text: buttonText
                font.pixelSize: Appearance.font.pixelSize.small
                color: button.colText
            }
        }
    }

}
