import qs.config
import qs.modules.widgets
import qs.services

import QtQuick
import Quickshell.Services.Notifications

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 30
    leftPadding: 15
    rightPadding: 15
    buttonRadius: Appearance.rounding.small
    colBackground: (urgency == NotificationUrgency.Critical) ? Colors.colors.colSecondaryContainer : Colors.colors.colLayer4
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Colors.colors.colSecondaryContainerHover : Colors.colors.colLayer4Hover
    colRipple: (urgency == NotificationUrgency.Critical) ? Colors.colors.colSecondaryContainerActive : Colors.colors.colLayer4Active

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? Colors.m3colors.m3onSurfaceVariant : Colors.m3colors.m3onSurface
    }
}
