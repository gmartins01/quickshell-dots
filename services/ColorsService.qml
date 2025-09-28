pragma Singleton
pragma ComponentBehavior: Bound

import qs.config

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string colorsPath: Paths.shellColorsPath

    function init() {
        root.reapplyTheme();
    }

    function reapplyTheme() {
        colorsReader.reload();
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent);
        for (const key in json) {
            if (json.hasOwnProperty(key)) {
                Colors.m3colors[key] = json[key];
            }
        }
    }

    Timer {
        id: delayedFileRead
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            root.applyColors(colorsReader.text());
        }
    }

    FileView {
        id: colorsReader
        path: Qt.resolvedUrl(root.colorsPath)
        watchChanges: true
        onFileChanged: {
            this.reload();
            delayedFileRead.start();
        }
        onLoaded: {
            root.applyColors(colorsReader.text());
        }
    }
}
