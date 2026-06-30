import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.1

Popup {
    id: panel
    modal: true
    focus: true
    width: Math.min(parent ? parent.width - 80 : 720, 760)
    height: Math.min(parent ? parent.height - 80 : 560, 620)
    closePolicy: Popup.CloseOnEscape

    property string storedKey: applicationSettings.value("fiberbase/licenseKey", "")
    property string licenseStatus: applicationSettings.value("fiberbase/status", storedKey.length ? "ACTIVE-OFFLINE" : "NOT ACTIVATED")
    property string lastSync: applicationSettings.value("fiberbase/lastSync", "Never")
    property string hardwareId: makeHardwareId()

    function makeHardwareId() {
        var seed = Qt.platform.os + "-" + Screen.width + "x" + Screen.height + "-SCTLP-V7";
        var h = 0;
        for (var i = 0; i < seed.length; i++) h = ((h << 5) - h) + seed.charCodeAt(i);
        h = Math.abs(h);
        return "SC-PC-" + h.toString(16).toUpperCase();
    }

    function validKey(k) {
        return /^SC-369-[A-Z0-9]{5}(-[A-Z0-9]{5})?$/.test(k.trim().toUpperCase());
    }

    function activate() {
        var k = keyInput.text.trim().toUpperCase();
        if (!validKey(k)) {
            statusLabel.text = "INVALID KEY FORMAT";
            statusLabel.color = "#ff5252";
            return;
        }
        applicationSettings.setValue("fiberbase/licenseKey", k);
        applicationSettings.setValue("fiberbase/hardwareId", hardwareId);
        applicationSettings.setValue("fiberbase/status", "ACTIVE-OFFLINE");
        applicationSettings.setValue("fiberbase/lastSync", new Date().toLocaleString());
        storedKey = k;
        licenseStatus = "ACTIVE-OFFLINE";
        lastSync = applicationSettings.value("fiberbase/lastSync", "Never");
        statusLabel.text = "ACTIVE - OFFLINE READY";
        statusLabel.color = "#00c853";
    }

    function syncNow() {
        applicationSettings.setValue("fiberbase/lastSync", new Date().toLocaleString());
        lastSync = applicationSettings.value("fiberbase/lastSync", "Never");
        syncNote.text = "Sync request logged. Connect Firebase endpoint in src/license/fiberbase for live revoke/suspend checks.";
    }

    background: Rectangle {
        radius: 18
        color: applicationAppearance.darkMode ? "#121212" : "#ffffff"
        border.color: "#d50000"
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Rectangle {
                width: 54; height: 54; radius: 14
                color: "#d50000"
                Label { anchors.centerIn: parent; text: "SC"; color: "white"; font.bold: true; font.pixelSize: 20 }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "SOUND CAPTAIN FIBERBASE V7"; font.pixelSize: 24; font.bold: true }
                Label { text: "Offline-first license with sync-ready revoke control"; opacity: 0.75 }
            }
            Button { text: "Close"; onClicked: panel.close() }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#d50000"; opacity: 0.45 }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 14
            columnSpacing: 12

            Label { text: "License Key"; font.bold: true }
            TextField {
                id: keyInput
                Layout.fillWidth: true
                placeholderText: "SC-369-XXXXX"
                text: storedKey
                selectByMouse: true
                font.capitalization: Font.AllUppercase
            }

            Label { text: "Hardware ID"; font.bold: true }
            RowLayout {
                Layout.fillWidth: true
                TextField { text: hardwareId; readOnly: true; Layout.fillWidth: true }
                Button { text: "Copy"; onClicked: hardwareIdFieldCopy.text = hardwareId }
            }

            Label { text: "Status"; font.bold: true }
            Label { id: statusLabel; text: licenseStatus; color: licenseStatus.indexOf("ACTIVE") >= 0 ? "#00c853" : "#ff5252"; font.bold: true }

            Label { text: "Last Sync"; font.bold: true }
            Label { text: lastSync }
        }

        RowLayout {
            Layout.fillWidth: true
            Button { text: "Activate"; Material.background: "#d50000"; Material.foreground: "white"; onClicked: activate() }
            Button { text: "Sync Now"; onClicked: syncNow() }
            Button { text: "Request License"; onClicked: requestText.text = "Send this Hardware ID to Sound Captain: " + hardwareId }
            Item { Layout.fillWidth: true }
        }

        Label { id: syncNote; Layout.fillWidth: true; wrapMode: Text.WordWrap; opacity: 0.75; text: "Key format locked: SC-369-XXXXX. This panel stores encrypted-ready local state and is prepared for Firebase revoke/suspend sync." }
        TextField { id: hardwareIdFieldCopy; visible: false }
        Label { id: requestText; Layout.fillWidth: true; wrapMode: Text.WordWrap; color: "#d50000" }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: applicationAppearance.darkMode ? "#1d1d1d" : "#f5f5f5"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Label { text: "Admin rules planned"; font.bold: true; font.pixelSize: 16 }
                Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: "Active / Suspended / Revoked / Expired / Lifetime keys. Offline use stays available, but every sync can enforce revoke from FiberBase." }
            }
        }
    }
}
