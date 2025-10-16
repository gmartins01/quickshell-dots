import qs.config
import qs.modules.widgets
import "./calendar_layout.js" as CalendarLayout

import QtQuick
import QtQuick.Layouts

StyledPanel {
    id: root

    // preferredWidth: calendarItem.implicitWidth
    // preferredHeight: calendarItem.implicitHeight
    panelBackgroundColor: Colors.colLayer1
    panelKeyboardFocus: true

    panelContent: Item {
        id: calendarItem

        anchors.margins: 20
        property int monthShift: 0
        property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
        property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)

        width: calendarColumn.width
        implicitHeight: calendarColumn.height + 10 * 2

        Binding {
            target: root
            property: "preferredWidth"
            value: calendarItem.width + 15
        }
        Binding {
            target: root
            property: "preferredHeight"
            value: calendarItem.implicitHeight + 15
        }

        Keys.onPressed: event => {
            if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
                if (event.key === Qt.Key_PageDown) {
                    monthShift++;
                } else if (event.key === Qt.Key_PageUp) {
                    monthShift--;
                }
                event.accepted = true;
            }
        }
        MouseArea {
            anchors.fill: parent
            onWheel: event => {
                if (event.angleDelta.y > 0) {
                    monthShift--;
                } else if (event.angleDelta.y < 0) {
                    monthShift++;
                }
            }
        }

        ColumnLayout {
            id: calendarColumn
            anchors.centerIn: parent
            spacing: 5

            // Calendar header
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                CalendarHeaderButton {
                    clip: true
                    buttonText: `${monthShift != 0 ? "• " : ""}${viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")}`
                    tooltipText: (monthShift === 0) ? "" : "Jump to current month"
                    downAction: () => {
                        monthShift = 0;
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                }
                CalendarHeaderButton {
                    forceCircle: true
                    downAction: () => {
                        monthShift--;
                    }
                    contentItem: MaterialIcon {
                        text: "chevron_left"
                        iconSize: Appearance.font.pixelSize.larger
                        horizontalAlignment: Text.AlignHCenter
                        color: Colors.colOnLayer1
                    }
                }
                CalendarHeaderButton {
                    forceCircle: true
                    downAction: () => {
                        monthShift++;
                    }
                    contentItem: MaterialIcon {
                        text: "chevron_right"
                        iconSize: Appearance.font.pixelSize.larger
                        horizontalAlignment: Text.AlignHCenter
                        color: Colors.colOnLayer1
                    }
                }
            }

            // Week days row
            RowLayout {
                id: weekDaysRow
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: false
                spacing: 5
                Repeater {
                    model: CalendarLayout.weekDays
                    delegate: CalendarDayButton {
                        day: modelData.day
                        isToday: modelData.today
                        isWeek: true
                        bold: true
                        enabled: false
                    }
                }
            }

            // Real week rows
            Repeater {
                id: calendarRows
                // model: calendarLayout
                model: 6
                delegate: RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: false
                    spacing: 5
                    Repeater {
                        model: Array(7).fill(modelData)
                        delegate: CalendarDayButton {
                            day: calendarLayout[modelData][index].day
                            isToday: calendarLayout[modelData][index].today
                        }
                    }
                }
            }
        }
    }
}
