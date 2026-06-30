import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.1

Popup {
    id: insight
    modal: true
    focus: true
    width: Math.min(parent ? parent.width - 70 : 860, 900)
    height: Math.min(parent ? parent.height - 70 : 640, 700)
    closePolicy: Popup.CloseOnEscape

    function n(v, d) { var x = parseFloat(v); return isNaN(x) ? d : x; }
    function analyze() {
        var sub = n(subDistance.text, 0);
        var top = n(topDistance.text, 0);
        var xo = Math.max(20, n(crossover.text, 80));
        var diff = sub - top;
        var ms = diff / 343 * 1000;
        var period = 1000 / xo;
        var phase = (ms / period) * 360;
        while (phase > 180) phase -= 360;
        while (phase < -180) phase += 360;
        var absPhase = Math.abs(phase);
        var confidence = Math.max(45, Math.round(100 - absPhase / 2));
        var polarity = absPhase > 120 ? "Try polarity invert and re-measure at crossover." : "Keep polarity normal first, then verify with transfer function.";
        var delayTarget = ms > 0 ? "Add about " + Math.abs(ms).toFixed(2) + " ms delay to TOP side." : "Add about " + Math.abs(ms).toFixed(2) + " ms delay to SUB side.";
        if (Math.abs(ms) < 0.15) delayTarget = "Distance difference is very small. Start with 0 ms and verify.";
        result.text = "Captain Insight™\n\n" +
            "Crossover: " + xo.toFixed(0) + " Hz\n" +
            "Distance difference: " + diff.toFixed(2) + " m\n" +
            "Estimated time offset: " + ms.toFixed(2) + " ms\n" +
            "Estimated phase at crossover: " + phase.toFixed(0) + "°\n\n" +
            "Action: " + delayTarget + "\n" +
            "Polarity: " + polarity + "\n" +
            "Measurement confidence before re-check: " + confidence + "%\n\n" +
            "Workflow: set delay → play crossover tone → check magnitude/coherence → invert polarity only if summation improves.";
    }

    background: Rectangle { radius: 18; color: applicationAppearance.darkMode ? "#101010" : "#ffffff"; border.color: "#d50000"; border.width: 2 }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Rectangle { width: 54; height: 54; radius: 14; color: "#d50000"; Label { anchors.centerIn: parent; text: "AI"; color: "white"; font.bold: true; font.pixelSize: 20 } }
            ColumnLayout { Layout.fillWidth: true; spacing: 2; Label { text: "Captain Insight™"; font.pixelSize: 26; font.bold: true } Label { text: "Exclusive Sound Captain quick decision assistant"; opacity: 0.75 } }
            Button { text: "Close"; onClicked: insight.close() }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Label { text: "Sub distance from mic (m)" }
            TextField { id: subDistance; Layout.fillWidth: true; text: "4.0"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
            Label { text: "Top distance from mic (m)" }
            TextField { id: topDistance; Layout.fillWidth: true; text: "3.2"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
            Label { text: "Crossover frequency (Hz)" }
            TextField { id: crossover; Layout.fillWidth: true; text: "80"; inputMethodHints: Qt.ImhDigitsOnly }
        }

        RowLayout { Button { text: "Analyze"; Material.background: "#d50000"; Material.foreground: "white"; onClicked: analyze() } Label { text: "Core measurement engine unchanged."; opacity: 0.7 } }

        TextArea {
            id: result
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
            wrapMode: Text.WordWrap
            text: "Enter sub/top distance and crossover, then press Analyze.\n\nThis tool gives practical delay, polarity and confidence suggestions without changing measurement data."
        }
    }
}
