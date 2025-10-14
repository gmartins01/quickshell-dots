pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances
    property bool appleDisplayPresent: false

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData === screen);
    }

    function getAvailableMethods(): list<string> {
        var methods = [];
        if (monitors.some(m => m.isDdc))
            methods.push("ddcutil");
        if (monitors.some(m => !m.isDdc))
            methods.push("internal");
        if (appleDisplayPresent)
            methods.push("apple");
        return methods;
    }

    function increaseBrightness(): void {
        monitors.forEach(m => m.increaseBrightness());
    }

    function decreaseBrightness(): void {
        monitors.forEach(m => m.decreaseBrightness());
    }

    function getDetectedDisplays(): list<var> {
        return detectedDisplays;
    }

    reloadableId: "brightness"

    Component.onCompleted: {
        console.log("Brightness ", "Service started");
    }

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants
        model: Quickshell.screens
        Monitor {}
    }

    // Check for Apple Display support
    Process {
        running: true
        command: ["sh", "-c", "which asdbctl >/dev/null 2>&1 && asdbctl get || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: root.appleDisplayPresent = text.trim().length > 0
        }
    }

    // Detect DDC monitors
    Process {
        id: ddcProc
        property list<var> ddcMonitors: []
        command: ["ddcutil", "detect", "--sleep-multiplier=0.5"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Do not filter out invalid displays. For some reason --brief returns some invalid which works fine
                var displays = text.trim().split("\n\n");

                ddcProc.ddcMonitors = displays.map(d => {
                    var ddcModelMatc = d.match(/This monitor does not support DDC\/CI/);
                    var modelMatch = d.match(/Model:\s*(.*)/);
                    var busMatch = d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/);
                    var ddcModel = ddcModelMatc ? ddcModelMatc.length > 0 : false;
                    var model = modelMatch ? modelMatch[1] : "Unknown";
                    var bus = busMatch ? busMatch[1] : "Unknown";
                    // Logger.log("Detected DDC Monitor:", model, "on bus", bus, "is DDC:", !ddcModel);
                    return {
                        "model": model,
                        "busNum": bus,
                        "isDdc": !ddcModel
                    };
                });
                root.ddcMonitors = ddcProc.ddcMonitors.filter(m => m.isDdc);
            }
        }
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: root.ddcMonitors.some(m => m.model === modelData.model)
        readonly property string busNum: root.ddcMonitors.find(m => m.model === modelData.model)?.busNum ?? ""
        readonly property bool isAppleDisplay: root.appleDisplayPresent && modelData.model.startsWith("StudioDisplay")
        readonly property string method: isAppleDisplay ? "apple" : (isDdc ? "ddcutil" : "internal")

        property real brightness
        property real lastBrightness: 0
        property real queuedBrightness: NaN

        // For internal displays - store the backlight device path
        property string backlightDevice: ""
        property string brightnessPath: ""
        property string maxBrightnessPath: ""
        property int maxBrightness: 100
        property bool ignoreNextChange: false

        // Signal for brightness changes
        signal brightnessUpdated(real newBrightness)

        // FileView to watch for external brightness changes (internal displays only)
        readonly property FileView brightnessWatcher: FileView {
            id: brightnessWatcher
            // Only set path for internal displays with a valid brightness path
            path: (!monitor.isDdc && !monitor.isAppleDisplay && monitor.brightnessPath !== "") ? monitor.brightnessPath : ""
            watchChanges: path !== ""
            onFileChanged: {
                reload();
                if (monitor.ignoreNextChange) {
                    monitor.ignoreNextChange = false;
                    return;
                }
                if (text() === "")
                    return;
                var current = parseInt(text().trim());
                if (!isNaN(current) && monitor.maxBrightness > 0) {
                    var newBrightness = current / monitor.maxBrightness;
                    // Only update if it's actually different (avoid feedback loops)
                    if (Math.abs(newBrightness - monitor.brightness) > 0.01) {
                        monitor.brightness = newBrightness;
                        monitor.brightnessUpdated(monitor.brightness);
                        //Logger.log("Brightness", "External change detected:", monitor.modelData.name, monitor.brightness)
                    }
                }
            }
        }

        readonly property Process initProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
                    var dataText = text.trim();
                    if (dataText === "") {
                        return;
                    }

                    //Logger.log("Brightness", "Raw brightness data for", monitor.modelData.name + ":", dataText)
                    if (monitor.isAppleDisplay) {
                        var val = parseInt(dataText);
                        if (!isNaN(val)) {
                            monitor.brightness = val / 101;
                            Logger.log("Brightness", "Apple display brightness:", monitor.brightness);
                        }
                    } else if (monitor.isDdc) {
                        var parts = dataText.split(" ");
                        if (parts.length >= 4) {
                            var current = parseInt(parts[3]);
                            var max = parseInt(parts[4]);
                            if (!isNaN(current) && !isNaN(max) && max > 0) {
                                monitor.brightness = current / max;
                                console.log("Brightness", "DDC brightness:", current + "/" + max + " =", monitor.brightness);
                            }
                        }
                    } else {
                        // Internal backlight - parse the response which includes device path
                        var lines = dataText.split("\n");
                        if (lines.length >= 3) {
                            monitor.backlightDevice = lines[0];
                            monitor.brightnessPath = monitor.backlightDevice + "/brightness";
                            monitor.maxBrightnessPath = monitor.backlightDevice + "/max_brightness";

                            var current = parseInt(lines[1]);
                            var max = parseInt(lines[2]);
                            if (!isNaN(current) && !isNaN(max) && max > 0) {
                                monitor.maxBrightness = max;
                                monitor.brightness = current / max;
                                console.log("Brightness", "Internal brightness:", current + "/" + max + " =", monitor.brightness);
                                console.log("Brightness", "Using backlight device:", monitor.backlightDevice);
                            }
                        }
                    }

                    // Always update
                    monitor.brightnessUpdated(monitor.brightness);
                }
            }
        }
        // Timer for debouncing rapid changes
        readonly property Timer timer: Timer {
            interval: 200
            onTriggered: {
                if (!isNaN(monitor.queuedBrightness)) {
                    monitor.setBrightness(monitor.queuedBrightness);
                    monitor.queuedBrightness = NaN;
                }
            }
        }

        function increaseBrightness(): void {
            var stepSize = Settings.data.brightness.brightnessStep / 100.0;
            setBrightnessDebounced(monitor.brightness + stepSize);
        }

        function decreaseBrightness(): void {
            var stepSize = Settings.data.brightness.brightnessStep / 100.0;
            setBrightnessDebounced(monitor.brightness - stepSize);
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            var rounded = Math.round(value * 100);

            if (Math.round(monitor.brightness * 100) === rounded)
                return;
            if (isDdc && timer.running) {
                monitor.queuedBrightness = value;
                return;
            }

            monitor.brightness = value;
            brightnessUpdated(monitor.brightness);

            if (isAppleDisplay) {
                Quickshell.execDetached(["asdbctl", "set", rounded]);
            } else if (isDdc) {
                Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", rounded]);
            } else {
                monitor.ignoreNextChange = true;
                Quickshell.execDetached(["brightnessctl", "s", rounded + "%"]);
            }

            if (isDdc) {
                timer.restart();
            }
        }

        function setBrightnessDebounced(value: real): void {
            monitor.queuedBrightness = value;
            timer.restart();
        }

        function initBrightness(): void {
            if (isAppleDisplay) {
                initProc.command = ["asdbctl", "get"];
            } else if (isDdc) {
                initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
            } else {
                // Internal backlight - find the first available backlight device and get its info
                // This now returns: device_path, current_brightness, max_brightness (on separate lines)
                initProc.command = ["sh", "-c", "for dev in /sys/class/backlight/*; do " + "  if [ -f \"$dev/brightness\" ] && [ -f \"$dev/max_brightness\" ]; then " + "    echo \"$dev\"; " + "    cat \"$dev/brightness\"; " + "    cat \"$dev/max_brightness\"; " + "    break; " + "  fi; " + "done"];
            }
            initProc.running = true;
        }

        onBusNumChanged: initBrightness()
        Component.onCompleted: initBrightness()
    }
}
