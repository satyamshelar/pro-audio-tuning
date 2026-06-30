import QtQuick 2.7
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

Item {
    width: 420
    height: 300

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Label { text: "Sound Captain Delay Calculator"; font.pixelSize: 20 }

        TextField {
            id: distance
            placeholderText: "Distance in feet"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        Label {
            text: distance.text === "" ? "Delay: 0 ms" :
                  "Delay: " + (parseFloat(distance.text) / 1.13).toFixed(2) + " ms"
            font.pixelSize: 18
        }

        Label {
            text: "Formula: feet ÷ 1.13 = ms"
            opacity: 0.7
        }
    }
}