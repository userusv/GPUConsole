import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window

    visible: true
    width: 1400
    height: 900
    minimumWidth: 1100
    minimumHeight: 700

    title: "GPUConsole"

    Dialog {
        id: aboutDialog

        title: "About GPUConsole"
        modal: true
        anchors.centerIn: parent
        width: 430

        standardButtons: Dialog.Ok

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                text: "GPUConsole"
                font.pixelSize: 24
                font.bold: true
                color: window.textColor
                Layout.fillWidth: true
            }

            Label {
                text: "NVIDIA GPU monitoring dashboard"
                color: window.secondaryText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: window.borderColor
            }

            Label {
                text: "Developed by userusv"
                color: window.textColor
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: "GitHub: github.com/userusv"
                color: window.graphColor
                Layout.fillWidth: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("https://github.com/userusv")
                }
            }

            Label {
                text: "© 2026 userusv"
                color: window.secondaryText
                Layout.fillWidth: true
            }
        }
    }

    property bool darkMode: false

    // =========================================================
    // THEME
    // =========================================================

    property color backgroundColor:
        darkMode ? "#111318" : "#F5F3EF"

    property color surfaceColor:
        darkMode ? "#1B1E24" : "#FFFFFF"

    property color surfaceSecondary:
        darkMode ? "#232730" : "#F0EEEA"

    property color borderColor:
        darkMode ? "#30343D" : "#DDD9D2"

    property color textColor:
        darkMode ? "#F2F2F2" : "#252525"

    property color secondaryText:
        darkMode ? "#A8ADB7" : "#686868"

    property color mutedText:
        darkMode ? "#858A94" : "#777777"

    property color graphColor:
        "#E95420"

    property color gridColor:
        darkMode ? "#343942" : "#E4E1DB"

    property int sectionRadius: 12

    // =========================================================
    // DISPLAY HELPERS
    // =========================================================

    function metricText(value, decimals, suffix) {
        return Number(value) < 0
                ? "Not available"
                : Number(value).toFixed(decimals) + suffix
    }

    function integerMetricText(value, suffix) {
        return Number(value) < 0
                ? "Not available"
                : Number(value) + suffix
    }

    color: backgroundColor

    // =========================================================
    // MAIN SCROLL VIEW
    // =========================================================

    ScrollView {
        id: scrollView

        anchors.fill: parent

        clip: true

        ScrollBar.vertical.policy:
            ScrollBar.AsNeeded

        ColumnLayout {
            id: page

            width: Math.max(
                       scrollView.width - 32,
                       1000
                   )

            anchors.margins: 16

            spacing: 14

            // =================================================
            // HEADER
            // =================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 72

                radius: 14

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 22
                    anchors.rightMargin: 18

                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 2

                        Label {
                            text: "GPUConsole"

                            font.pixelSize: 25
                            font.bold: true

                            color: textColor
                        }

                        Label {
                            text: "GPU monitoring dashboard"

                            font.pixelSize: 13

                            color: secondaryText
                        }
                    }

                    Label {
                        text:
                            gpuController.name ||
                            "No GPU"

                        font.pixelSize: 14
                        font.bold: true

                        color: graphColor
                    }

                    Button {
                        text: "About"

                        onClicked: aboutDialog.open()
                    }

                    Switch {
                        id: themeSwitch

                        checked: window.darkMode

                        text:
                            checked ? "Dark" : "Light"

                        onToggled: {
                            window.darkMode = checked
                        }
                    }
                }
            }

            // =================================================
            // GPU SELECTOR
            // =================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 12

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    spacing: 14

                    Label {
                        text: "GPU"

                        font.pixelSize: 14
                        font.bold: true

                        color: textColor
                    }

                    ComboBox {
                        id: gpuSelector

                        Layout.preferredWidth: 360

                        model:
                            gpuController.gpuNames

                        currentIndex:
                            gpuController.selectedGpu

                        onActivated: {
                            gpuController.selectedGpu =
                                currentIndex
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text:
                            gpuController.vendor ||
                            "Unknown vendor"

                        font.pixelSize: 13

                        color: secondaryText
                    }
                }
            }

            // =================================================
            // GPU IDENTITY
            // =================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 96

                radius: 12

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent

                    anchors.margins: 18

                    spacing: 5

                    Label {
                        text:
                            gpuController.name ||
                            "No GPU detected"

                        font.pixelSize: 20
                        font.bold: true

                        color: textColor
                    }

                    Label {
                        text:
                            gpuController.uuid
                            ? "UUID: "
                              + gpuController.uuid
                            : "UUID: Not available"

                        font.pixelSize: 12

                        color: secondaryText

                        elide:
                            Text.ElideMiddle

                        Layout.fillWidth: true
                    }
                }
            }

            // =================================================
            // GPU OVERVIEW
            // =================================================

            Rectangle {
                id: overviewSection

                Layout.fillWidth: true

                property bool expanded: true

                implicitHeight:
                    overviewColumn.implicitHeight

                radius: sectionRadius

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    id: overviewColumn

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58

                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                overviewSection.expanded =
                                    !overviewSection.expanded
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 18
                            anchors.rightMargin: 18

                            Label {
                                text:
                                    overviewSection.expanded
                                    ? "▼"
                                    : "▶"

                                font.pixelSize: 13

                                color: graphColor
                            }

                            Label {
                                text: "GPU Overview"

                                font.pixelSize: 16
                                font.bold: true

                                color: textColor
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text:
                                    gpuController.gpuUtilization < 0
                            ? "Not available"
                            : Math.round(
                                  gpuController.gpuUtilization
                              ) + "% GPU"

                                color: secondaryText

                                font.pixelSize: 12
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        visible:
                            overviewSection.expanded

                        spacing: 14

                        // =====================================
                        // METRIC CARDS
                        // =====================================

                        GridLayout {
                            Layout.fillWidth: true

                            columns: 4

                            columnSpacing: 12
                            rowSpacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "GPU Utilization"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            metricText(
                                                gpuController.gpuUtilization,
                                                1,
                                                "%"
                                            )

                                        color: textColor

                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "VRAM Usage"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            gpuController.memoryUsed < 0 ||
                                            gpuController.memoryTotal < 0
                                            ? "Not available"
                                            : gpuController.memoryUsed.toFixed(0)
                                              + " / "
                                              + gpuController.memoryTotal.toFixed(0)
                                              + " MiB"

                                        color: textColor

                                        font.pixelSize: 19
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "Temperature"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            metricText(
                                                gpuController.temperature,
                                                1,
                                                " °C"
                                            )

                                        color: textColor

                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text: "Power"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            metricText(
                                                gpuController.powerUsage,
                                                1,
                                                " W"
                                            )

                                        color: textColor

                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "Memory Utilization"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            metricText(
                                                gpuController.memoryUtilization,
                                                1,
                                                "%"
                                            )

                                        color: textColor

                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "Graphics Clock"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            integerMetricText(
                                                gpuController.graphicsClock,
                                                " MHz"
                                            )

                                        color: textColor

                                        font.pixelSize: 23
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "Memory Clock"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            integerMetricText(
                                                gpuController.memoryClock,
                                                " MHz"
                                            )

                                        color: textColor

                                        font.pixelSize: 23
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105

                                radius: 10

                                color: surfaceSecondary

                                ColumnLayout {
                                    anchors.fill: parent

                                    anchors.margins: 14

                                    Label {
                                        text:
                                            "Free VRAM"

                                        color:
                                            secondaryText

                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:
                                            metricText(
                                                gpuController.memoryFree,
                                                0,
                                                " MiB"
                                            )

                                        color: textColor

                                        font.pixelSize: 23
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // =====================================
                        // GPU GRAPH
                        // =====================================

                        LineChart {
                            Layout.fillWidth: true

                            title:
                                "GPU Utilization"

                            unit: "%"

                            values:
                                gpuController
                                .gpuUtilizationHistory

                            currentValue:
                                gpuController
                                .gpuUtilization

                            minValue: 0
                            maxValue: 100
                        }

                        // =====================================
                        // MEMORY GRAPH
                        // =====================================

                        LineChart {
                            Layout.fillWidth: true

                            title:
                                "Memory Utilization"

                            unit: "%"

                            values:
                                gpuController
                                .memoryUtilizationHistory

                            currentValue:
                                gpuController
                                .memoryUtilization

                            minValue: 0
                            maxValue: 100
                        }

                        // =====================================
                        // TEMPERATURE GRAPH
                        // =====================================

                        LineChart {
                            Layout.fillWidth: true

                            title:
                                "Temperature"

                            unit: "°C"

                            values:
                                gpuController
                                .temperatureHistory

                            currentValue:
                                gpuController
                                .temperature

                            minValue: 0
                            maxValue: 100
                        }

                        // =====================================
                        // POWER GRAPH
                        // =====================================

                        LineChart {
                            Layout.fillWidth: true

                            title:
                                "Power"

                            unit: "W"

                            values:
                                gpuController
                                .powerHistory

                            currentValue:
                                gpuController
                                .powerUsage

                            minValue: 0

                            maxValue:
                                Math.max(
                                    100,
                                    gpuController.powerLimit
                                )
                        }
                    }
                }
            }

            // =================================================
            // THERMAL & POWER
            // =================================================

            Rectangle {
                id: thermalSection

                Layout.fillWidth: true

                property bool expanded: false

                implicitHeight:
                    thermalColumn.implicitHeight

                radius: sectionRadius

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    id: thermalColumn

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58

                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                thermalSection.expanded =
                                    !thermalSection.expanded
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 18
                            anchors.rightMargin: 18

                            Label {
                                text:
                                    thermalSection.expanded
                                    ? "▼"
                                    : "▶"

                                color: graphColor
                            }

                            Label {
                                text:
                                    "Thermal & Power"

                                font.pixelSize: 16
                                font.bold: true

                                color: textColor
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text:
                                    gpuController.temperature < 0 ||
                                    gpuController.powerUsage < 0
                                    ? "Not available"
                                    : gpuController.temperature.toFixed(1)
                                      + " °C  •  "
                                      + gpuController.powerUsage.toFixed(1)
                                      + " W"

                                font.pixelSize: 12

                                color: secondaryText
                            }
                        }
                    }

                    GridLayout {
                        visible:
                            thermalSection.expanded

                        Layout.fillWidth: true

                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        Layout.bottomMargin: 18

                        columns: 4

                        columnSpacing: 12
                        rowSpacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82

                            radius: 9

                            color: surfaceSecondary

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.margins: 12

                                Label {
                                    text:
                                        "Temperature"

                                    color:
                                        secondaryText
                                }

                                Label {
                                    text:
                                        metricText(
                                            gpuController.temperature,
                                            1,
                                            " °C"
                                        )

                                    font.pixelSize: 21
                                    font.bold: true

                                    color: textColor
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82

                            radius: 9

                            color: surfaceSecondary

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.margins: 12

                                Label {
                                    text:
                                        "Power Usage"

                                    color:
                                        secondaryText
                                }

                                Label {
                                    text:
                                        metricText(
                                            gpuController.powerUsage,
                                            1,
                                            " W"
                                        )

                                    font.pixelSize: 21
                                    font.bold: true

                                    color: textColor
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82

                            radius: 9

                            color: surfaceSecondary

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.margins: 12

                                Label {
                                    text:
                                        "Power Limit"

                                    color:
                                        secondaryText
                                }

                                Label {
                                    text:
                                        gpuController.powerLimit > 0
                                        ? gpuController
                                          .powerLimit
                                          .toFixed(1)
                                          + " W"
                                        : "Not supported"

                                    font.pixelSize: 21
                                    font.bold: true

                                    color: textColor
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82

                            radius: 9

                            color: surfaceSecondary

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.margins: 12

                                Label {
                                    text:
                                        "Fan Speed"

                                    color:
                                        secondaryText
                                }

                                Label {
                                    text:
                                        gpuController.fanSpeed >= 0
                                        ? gpuController
                                          .fanSpeed
                                          + " %"
                                        : "Not supported"

                                    font.pixelSize: 21
                                    font.bold: true

                                    color: textColor
                                }
                            }
                        }
                    }
                }
            }

            // =================================================
            // HARDWARE DETAILS
            // =================================================

            Rectangle {
                id: hardwareSection

                Layout.fillWidth: true

                property bool expanded: false

                implicitHeight:
                    hardwareColumn.implicitHeight

                radius: sectionRadius

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    id: hardwareColumn

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58

                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                hardwareSection.expanded =
                                    !hardwareSection.expanded
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 18
                            anchors.rightMargin: 18

                            Label {
                                text:
                                    hardwareSection.expanded
                                    ? "▼"
                                    : "▶"

                                color: graphColor
                            }

                            Label {
                                text:
                                    "Hardware Details"

                                font.pixelSize: 16
                                font.bold: true

                                color: textColor
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text:
                                    gpuController.driverVersion ||
                                    "Driver unavailable"

                                font.pixelSize: 12

                                color: secondaryText
                            }
                        }
                    }

                    GridLayout {
                        visible:
                            hardwareSection.expanded

                        Layout.fillWidth: true

                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        Layout.bottomMargin: 18

                        columns: 3

                        columnSpacing: 12
                        rowSpacing: 12

                        HardwareItem {
                            label: "Vendor"

                            value:
                                gpuController.vendor
                        }

                        HardwareItem {
                            label: "GPU"

                            value:
                                gpuController.name
                        }

                        HardwareItem {
                            label: "Driver"

                            value:
                                gpuController.driverVersion
                        }

                        HardwareItem {
                            label: "CUDA"

                            value:
                                gpuController.cudaVersion
                        }

                        HardwareItem {
                            label: "Fan Speed"

                            value:
                                gpuController.fanSpeed >= 0
                                ? gpuController.fanSpeed + " %"
                                : "Not supported"
                        }

                        HardwareItem {
                            label:
                                "Performance State"

                            value:
                                gpuController
                                .performanceState >= 0
                                ? "P"
                                  + gpuController
                                  .performanceState
                                : "Not supported"
                        }

                        HardwareItem {
                            label:
                                "PCIe Generation"

                            value:
                                gpuController
                                .pcieGeneration >= 0
                                ? "Gen "
                                  + gpuController
                                  .pcieGeneration
                                : "Not supported"
                        }

                        HardwareItem {
                            label:
                                "PCIe Link Width"

                            value:
                                gpuController
                                .pcieLinkWidth >= 0
                                ? "x"
                                  + gpuController
                                  .pcieLinkWidth
                                : "Not supported"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 78

                            radius: 9

                            color: surfaceSecondary

                            ColumnLayout {
                                anchors.fill: parent

                                anchors.margins: 12

                                Label {
                                    text: "UUID"

                                    font.pixelSize: 11

                                    color:
                                        secondaryText
                                }

                                Label {
                                    text:
                                        gpuController.uuid ||
                                        "Not available"

                                    font.pixelSize: 12

                                    color: textColor

                                    elide:
                                        Text.ElideMiddle

                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // =================================================
            // GPU PROCESSES
            // =================================================

            Rectangle {
                id: processSection

                Layout.fillWidth: true

                property bool expanded: true

                implicitHeight:
                    processColumn.implicitHeight

                radius: sectionRadius

                color: surfaceColor

                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    id: processColumn

                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: 0

                    // -----------------------------------------
                    // PROCESS HEADER
                    // -----------------------------------------

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58

                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                processSection.expanded =
                                    !processSection.expanded
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 18
                            anchors.rightMargin: 18

                            spacing: 10

                            Label {
                                text:
                                    processSection.expanded
                                    ? "▼"
                                    : "▶"

                                color: graphColor

                                font.pixelSize: 12
                            }

                            Label {
                                text:
                                    "GPU Processes"

                                font.pixelSize: 16
                                font.bold: true

                                color: textColor
                            }

                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 22

                                radius: 11

                                color:
                                    gpuController.processes
                                    .length > 0
                                    ? (
                                        darkMode
                                        ? "#38261F"
                                        : "#FFF0E9"
                                      )
                                    : surfaceSecondary

                                Label {
                                    anchors.centerIn: parent

                                    text:
                                        gpuController
                                        .processes
                                        .length

                                    color:
                                        gpuController
                                        .processes
                                        .length > 0
                                        ? graphColor
                                        : secondaryText

                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Label {
                                text:
                                    gpuController
                                    .processes
                                    .length === 1
                                    ? "1 process"
                                    : gpuController
                                      .processes
                                      .length
                                      + " processes"

                                font.pixelSize: 12

                                color: secondaryText
                            }
                        }
                    }

                    // -----------------------------------------
                    // PROCESS CONTENT
                    // -----------------------------------------

                    ColumnLayout {
                        visible:
                            processSection.expanded

                        Layout.fillWidth: true

                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        Layout.bottomMargin: 18

                        spacing: 0

                        Rectangle {
                            id: processTable

                            Layout.fillWidth: true

                            Layout.preferredHeight:
                                gpuController.processes
                                .length === 0
                                ? 120
                                : Math.min(
                                    430,
                                    52
                                    +
                                    gpuController
                                    .processes
                                    .length
                                    * 48
                                  )

                            radius: 9

                            color: surfaceSecondary

                            border.color: borderColor
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent

                                spacing: 0

                                // ---------------------------------
                                // TABLE HEADER
                                // ---------------------------------

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 44

                                    color:
                                        darkMode
                                        ? "#292D35"
                                        : "#E7E4DE"

                                    RowLayout {
                                        anchors.fill: parent

                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 14

                                        spacing: 12

                                        Label {
                                            Layout.fillWidth: true

                                            text:
                                                "PROCESS"

                                            color:
                                                secondaryText

                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Label {
                                            Layout.preferredWidth: 90

                                            text: "PID"

                                            color:
                                                secondaryText

                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Label {
                                            Layout.preferredWidth: 140

                                            text: "VRAM"

                                            color:
                                                secondaryText

                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Label {
                                            Layout.preferredWidth: 110

                                            text: "TYPE"

                                            color:
                                                secondaryText

                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }

                                // ---------------------------------
                                // PROCESS LIST
                                // ---------------------------------

                                ListView {
                                    id: processList

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    clip: true

                                    model:
                                        gpuController.processes

                                    spacing: 0

                                    ScrollBar.vertical:
                                        ScrollBar {
                                            policy:
                                                ScrollBar.AsNeeded
                                        }

                                    delegate: Rectangle {
                                        width:
                                            processList.width

                                        height: 48

                                        color:
                                            index % 2 === 0
                                            ? surfaceColor
                                            : surfaceSecondary

                                        RowLayout {
                                            anchors.fill: parent

                                            anchors.leftMargin: 14
                                            anchors.rightMargin: 14

                                            spacing: 12

                                            // -------------------------
                                            // PROCESS NAME
                                            // -------------------------

                                            Label {
                                                id: processName

                                                Layout.fillWidth: true

                                                text:
                                                    modelData.name

                                                color: textColor

                                                font.pixelSize: 13

                                                elide:
                                                    Text.ElideMiddle

                                                ToolTip.visible:
                                                    processMouse.containsMouse

                                                ToolTip.text:
                                                    modelData.name

                                                MouseArea {
                                                    id: processMouse

                                                    anchors.fill:
                                                        parent

                                                    hoverEnabled: true
                                                }
                                            }

                                            // -------------------------
                                            // PID
                                            // -------------------------

                                            Label {
                                                Layout.preferredWidth: 90

                                                text:
                                                    modelData.pid

                                                color:
                                                    secondaryText

                                                font.pixelSize: 12
                                            }

                                            // -------------------------
                                            // VRAM
                                            // -------------------------

                                            Label {
                                                Layout.preferredWidth: 140

                                                text:
                                                    Number(
                                                        modelData
                                                        .memoryMiB
                                                    ).toFixed(1)
                                                    + " MiB"

                                                color: textColor

                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            // -------------------------
                                            // TYPE
                                            // -------------------------

                                            Rectangle {
                                                Layout.preferredWidth: 90
                                                Layout.preferredHeight: 25

                                                radius: 12

                                                color:
                                                    modelData.type
                                                    === "Compute"
                                                    ? (
                                                        darkMode
                                                        ? "#35251F"
                                                        : "#FFF0E9"
                                                      )
                                                    : (
                                                        darkMode
                                                        ? "#282C33"
                                                        : "#E8E6E1"
                                                      )

                                                Label {
                                                    anchors.centerIn:
                                                        parent

                                                    text:
                                                        modelData.type

                                                    color:
                                                        modelData.type
                                                        === "Compute"
                                                        ? graphColor
                                                        : secondaryText

                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }

                                    // ---------------------------------
                                    // EMPTY STATE
                                    // ---------------------------------

                                    Column {
                                        anchors.centerIn: parent

                                        spacing: 6

                                        visible:
                                            gpuController.processes
                                            .length === 0

                                        Label {
                                            anchors.horizontalCenter:
                                                parent.horizontalCenter

                                            text:
                                                "No GPU processes detected"

                                            color: textColor

                                            font.pixelSize: 14
                                            font.bold: true
                                        }

                                        Label {
                                            anchors.horizontalCenter:
                                                parent.horizontalCenter

                                            text:
                                                "No applications are currently using this GPU."

                                            color: secondaryText

                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =================================================
            // BOTTOM SPACING
            // =================================================

            Item {
                Layout.preferredHeight: 20
            }
        }
    }

    // =========================================================
    // HARDWARE ITEM COMPONENT
    // =========================================================

    component HardwareItem: Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 78

        radius: 9

        color: surfaceSecondary

        ColumnLayout {
            anchors.fill: parent

            anchors.margins: 12

            Label {
                text: label

                font.pixelSize: 11

                color: secondaryText
            }

            Label {
                text:
                    value ||
                    "Not available"

                font.pixelSize: 13
                font.bold: true

                color: textColor

                elide:
                    Text.ElideMiddle

                Layout.fillWidth: true
            }
        }
    }

    // =========================================================
    // LINE CHART COMPONENT
    // =========================================================

    component LineChart: Rectangle {
        id: chart

        property string title: ""
        property string unit: ""

        property var values: []

        property real currentValue: 0

        property real minValue: 0
        property real maxValue: 100

        Layout.fillWidth: true
        Layout.preferredHeight: 285

        radius: 12

        color: surfaceColor

        border.color: borderColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent

            spacing: 0

            // ---------------------------------------------
            // CHART HEADER
            // ---------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54

                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    Label {
                        text:
                            chart.title

                        font.pixelSize: 14
                        font.bold: true

                        color: textColor
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 88
                        Layout.preferredHeight: 30

                        radius: 8

                        color:
                            darkMode
                            ? "#30231D"
                            : "#FFF0E9"

                        Label {
                            anchors.centerIn: parent

                            text:
                                chart.currentValue < 0
                            ? "Not available"
                            : chart.currentValue.toFixed(1)
                              + " "
                              + chart.unit

                            font.pixelSize: 12
                            font.bold: true

                            color: graphColor
                        }
                    }
                }
            }

            // ---------------------------------------------
            // CHART AREA
            // ---------------------------------------------

            Item {
                id: chartArea

                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.leftMargin: 52
                Layout.rightMargin: 18
                Layout.bottomMargin: 32

                // -----------------------------------------
                // Y AXIS
                // -----------------------------------------

                Column {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: 38

                    spacing: 0

                    Label {
                        width: parent.width

                        text:
                            chart.maxValue.toFixed(0)

                        color: secondaryText

                        font.pixelSize: 10

                        horizontalAlignment:
                            Text.AlignRight
                    }

                    Item {
                        width: 1

                        height:
                            Math.max(
                                1,
                                parent.height - 40
                            )
                    }

                    Label {
                        width: parent.width

                        text:
                            chart.minValue.toFixed(0)

                        color: secondaryText

                        font.pixelSize: 10

                        horizontalAlignment:
                            Text.AlignRight
                    }
                }

                // -----------------------------------------
                // GRAPH
                // -----------------------------------------

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    anchors.leftMargin: 46

                    Canvas {
                        id: canvas

                        anchors.fill: parent

                        antialiasing: true

                        onPaint: {
                            var ctx =
                                getContext("2d")

                            ctx.clearRect(
                                0,
                                0,
                                width,
                                height
                            )

                            var graphWidth =
                                width

                            var graphHeight =
                                height

                            // -------------------------
                            // GRID
                            // -------------------------

                            ctx.lineWidth = 1

                            ctx.strokeStyle =
                                window.gridColor.toString()

                            for (
                                var gy = 0;
                                gy <= 4;
                                gy++
                            ) {
                                var yy =
                                    graphHeight
                                    * gy
                                    / 4

                                ctx.beginPath()

                                ctx.moveTo(
                                    0,
                                    yy
                                )

                                ctx.lineTo(
                                    graphWidth,
                                    yy
                                )

                                ctx.stroke()
                            }

                            for (
                                var gx = 0;
                                gx <= 4;
                                gx++
                            ) {
                                var xx =
                                    graphWidth
                                    * gx
                                    / 4

                                ctx.beginPath()

                                ctx.moveTo(
                                    xx,
                                    0
                                )

                                ctx.lineTo(
                                    xx,
                                    graphHeight
                                )

                                ctx.stroke()
                            }

                            // -------------------------
                            // WAITING STATE
                            // -------------------------

                            if (
                                !chart.values ||
                                chart.values.length < 2
                            ) {
                                ctx.fillStyle =
                                    window.secondaryText
                                    .toString()

                                ctx.font =
                                    "12px sans-serif"

                                ctx.fillText(
                                    "Waiting for data...",
                                    12,
                                    graphHeight / 2
                                )

                                return
                            }

                            // -------------------------
                            // VALUE RANGE
                            // -------------------------

                            var minV =
                                chart.minValue

                            var maxV =
                                chart.maxValue

                            if (maxV <= minV)
                                maxV =
                                    minV + 1

                            // -------------------------
                            // GRAPH LINE
                            // -------------------------

                            ctx.beginPath()

                            for (
                                var i = 0;
                                i < chart.values.length;
                                i++
                            ) {
                                var value =
                                    Number(
                                        chart.values[i]
                                    )

                                if (!isFinite(value))
                                    value = minV

                                value =
                                    Math.max(
                                        minV,
                                        Math.min(
                                            maxV,
                                            value
                                        )
                                    )

                                var x =
                                    chart.values.length === 1
                                    ? 0
                                    : i
                                      * graphWidth
                                      /
                                      (
                                          chart.values.length
                                          - 1
                                      )

                                var y =
                                    graphHeight
                                    -
                                    (
                                        (
                                            value - minV
                                        )
                                        /
                                        (
                                            maxV - minV
                                        )
                                    )
                                    *
                                    graphHeight

                                if (i === 0)
                                    ctx.moveTo(
                                        x,
                                        y
                                    )
                                else
                                    ctx.lineTo(
                                        x,
                                        y
                                    )
                            }

                            ctx.lineWidth = 2.5

                            ctx.strokeStyle =
                                window.graphColor.toString()

                            ctx.stroke()

                            // -------------------------
                            // CURRENT POINT
                            // -------------------------

                            var last =
                                Number(
                                    chart.values[
                                        chart.values.length
                                        - 1
                                    ]
                                )

                            last =
                                Math.max(
                                    minV,
                                    Math.min(
                                        maxV,
                                        last
                                    )
                                )

                            var lastX =
                                graphWidth

                            var lastY =
                                graphHeight
                                -
                                (
                                    (
                                        last - minV
                                    )
                                    /
                                    (
                                        maxV - minV
                                    )
                                )
                                *
                                graphHeight

                            ctx.beginPath()

                            ctx.arc(
                                lastX,
                                lastY,
                                4,
                                0,
                                Math.PI * 2
                            )

                            ctx.fillStyle =
                                window.graphColor.toString()

                            ctx.fill()
                        }

                        Connections {
                            target: chart

                            function onValuesChanged() {
                                canvas.requestPaint()
                            }

                            function onCurrentValueChanged() {
                                canvas.requestPaint()
                            }

                            function onMinValueChanged() {
                                canvas.requestPaint()
                            }

                            function onMaxValueChanged() {
                                canvas.requestPaint()
                            }
                        }

                        Connections {
                            target: window

                            function onDarkModeChanged() {
                                canvas.requestPaint()
                            }
                        }

                        Component.onCompleted: {
                            requestPaint()
                        }
                    }

                    // -----------------------------------------
                    // X AXIS
                    // -----------------------------------------

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        anchors.bottomMargin: -27

                        Label {
                            width:
                                parent.width / 5

                            text: "60s"

                            color: secondaryText

                            font.pixelSize: 10
                        }

                        Label {
                            width:
                                parent.width / 5

                            text: "45s"

                            color: secondaryText

                            font.pixelSize: 10

                            horizontalAlignment:
                                Text.AlignHCenter
                        }

                        Label {
                            width:
                                parent.width / 5

                            text: "30s"

                            color: secondaryText

                            font.pixelSize: 10

                            horizontalAlignment:
                                Text.AlignHCenter
                        }

                        Label {
                            width:
                                parent.width / 5

                            text: "15s"

                            color: secondaryText

                            font.pixelSize: 10

                            horizontalAlignment:
                                Text.AlignHCenter
                        }

                        Label {
                            width:
                                parent.width / 5

                            text: "now"

                            color: secondaryText

                            font.pixelSize: 10

                            horizontalAlignment:
                                Text.AlignRight
                        }
                    }
                }
            }
        }
    }
}
