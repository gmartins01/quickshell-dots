import qs.config

import QtQuick
import Quickshell
import Quickshell.Widgets

Rectangle {
    width: parent.width
    height: Math.max(1, 2)
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: "transparent"
        }
        GradientStop {
            position: 0.3
            color: Colors.m3colors.m3primary
        }
        GradientStop {
            position: 0.7
            color: Colors.m3colors.m3primary
        }
        GradientStop {
            position: 1.0
            color: "transparent"
        }
    }
}
