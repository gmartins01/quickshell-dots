pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: []
    })

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property bool inputMuted: !!source?.audio?.muted
    readonly property real inputVolume: source?.audio?.volume ?? 0

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources]
    }

    Connections {
        target: sink?.audio ?? null

        function onVolumeChanged() {
            console.log("Volume changed to: ", volume);
        }
    }
}
