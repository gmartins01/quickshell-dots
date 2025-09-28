pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Paths.shellConfigPath
    property alias options: configOptionsJsonAdapter
    property bool ready: false

    property string defaultWallpapersDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string defaultWallpaper: Quickshell.shellDir + "/assets/images/default_wallpaper.png"

    function setNestedValue(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.options;
        let parents = [obj];

        // Traverse and collect parent objects
        for (let i = 0; i < keys.length - 1; ++i) {
            if (!obj[keys[i]] || typeof obj[keys[i]] !== "object") {
                obj[keys[i]] = {};
            }
            obj = obj[keys[i]];
            parents.push(obj);
        }

        // Convert value to correct type using JSON.parse when safe
        let convertedValue = value;
        if (typeof value === "string") {
            let trimmed = value.trim();
            if (trimmed === "true" || trimmed === "false" || !isNaN(Number(trimmed))) {
                try {
                    convertedValue = JSON.parse(trimmed);
                } catch (e) {
                    convertedValue = value;
                }
            }
        }

        obj[keys[keys.length - 1]] = convertedValue;
    }

    FileView {
        path: root.filePath
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: root.ready = true
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        JsonAdapter {
            id: configOptionsJsonAdapter

            property JsonObject wallpaper: JsonObject {
                property bool enabled: true
                property string directory: defaultWallpapersDirectory
                property bool enableMultiMonitorDirectories: false
                property bool setWallpaperOnAllMonitors: true
                property string fillMode: "crop"
                property color fillColor: "#000000"
                property bool randomEnabled: false
                property int randomIntervalSec: 300 // 5 min
                property int transitionDuration: 1500 // 1500 ms
                property string transitionType: "random"
                property real transitionEdgeSmoothness: 0.05
                property list<var> monitors: []
            }

            property JsonObject bar: JsonObject {
                property string position: "top"
                property bool bottom: false // Instead of top
                property bool vertical: false
                property int cornerStyle: 0 // 0: Hug | 1: Float | 2: Plain rectangle
                property bool borderless: false // true for no grouping of items
                property string topLeftIcon: "spark" // Options: "distro" or any icon name in ~/.config/quickshell/ii/assets/icons
                property bool showBackground: true

                property list<string> screenList: [] // List of names, like "eDP-1", find out with 'hyprctl monitors' command

                property JsonObject tray: JsonObject {
                    property bool monochromeIcons: true
                    property bool invertPinnedItems: false // Makes the below a whitelist for the tray and blacklist for the pinned area
                    property list<string> pinnedItems: ["Fcitx"]
                }
                property JsonObject workspaces: JsonObject {
                    property bool monochromeIcons: true
                    property int shown: 10
                    property bool showAppIcons: true
                    property bool alwaysShowNumbers: false
                    property int showNumberDelay: 300 // milliseconds
                    property list<string> numberMap: ["1", "2"] // Characters to show instead of numbers on workspace indicator
                    property bool useNerdFont: false
                }
            }

            property JsonObject time: JsonObject {
                property string format: "hh:mm"
                property string dateFormat: "dddd, dd/MM"
                property string shortDateFormat: "dd/MM"
            }
        }
    }
}
