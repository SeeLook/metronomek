/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Column {
    id: tc

    property alias text: text.text
    property int tempo: 60
    property bool runAnimOnce: true

    signal tempoModified(var t)

    spacing: GLOB.fontSize()

    Text {
        id: text

        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: ActivPalette.text
    }

    Dial {
        id: tDial

        property real lastTime: new Date().getTime()
        property bool showHint: tDial.pressed

        function tapTempo() {
            var currTime = new Date().getTime();
            if (currTime - tDial.lastTime < 2000)
                tc.tempoModified(GLOB.bound(40, Math.round(60000 / (currTime - lastTime)), 240));

            tDial.lastTime = currTime;
        }

        width: Math.min(mainWindow.width, fm.height * 40) * 0.35
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        from: 40
        to: 240
        stepSize: 1
        wheelEnabled: true
        value: tempo
        onValueChanged: tempoModified(value)

        TipRect {
            id: tapRect

            property bool lighter: false

            anchors.centerIn: parent
            width: parent.width * 0.55
            height: parent.height * 0.55
            radius: width / 2
            color: Qt.lighter(ActivPalette.button, tDial.pressed || tapRect.lighter || tapArea.pressed ? 1.2 : 1)
            raised: !tapArea.pressed

            Text {
                anchors.centerIn: parent
                color: ActivPalette.buttonText
                text: tempo

                font {
                    pixelSize: parent.height * 0.3
                    bold: true
                }

            }

            MouseArea {
                id: tapArea

                anchors.fill: parent
                onClicked: tDial.tapTempo()
            }

        }

        AbstractButton {
            id: incrButt

            height: tDial.width / 6
            width: tDial.width / 6
            x: tDial.mirrored ? 0 : tDial.width - width
            onClicked: tDial.increase()

            indicator: Item {
                implicitHeight: tDial.width / 6
                implicitWidth: tDial.width / 6
                scale: incrButt.pressed ? 0.8 : 1

                Rectangle {
                    x: parent.width / 4
                    width: parent.width / 2
                    height: parent.height / 15
                    y: parent.height * 0.48
                    color: ActivPalette.text
                }

                Rectangle {
                    x: parent.width / 4
                    width: parent.width / 2
                    height: parent.height / 15
                    y: parent.height * 0.48
                    color: ActivPalette.text
                    rotation: 90
                }

                Behavior on scale {
                    NumberAnimation {
                    }

                }

            }

        }

        AbstractButton {
            id: decrButt

            height: tDial.width / 6
            width: tDial.width / 6
            x: tDial.mirrored ? tDial.width - width : 0
            onClicked: tDial.decrease()

            indicator: Item {
                implicitHeight: tDial.width / 6
                implicitWidth: tDial.width / 6
                scale: decrButt.pressed ? 0.8 : 1

                Rectangle {
                    x: parent.width / 4
                    width: parent.width / 2
                    height: parent.height / 15
                    y: parent.height * 0.48
                    color: ActivPalette.text
                }

                Behavior on scale {
                    NumberAnimation {
                    }

                }

            }

        }

        Rectangle {
            scale: tDial.showHint ? 1 : 0
            color: ActivPalette.highlight
            x: (tDial.width - width) / 2
            y: tDial.height
            width: tapText.width + fm.height / 2
            height: tapText.height + fm.height / 2
            radius: fm.height / 4

            Text {
                id: tapText

                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                color: ActivPalette.highlightedText
                text: qsTr("Tap tempo<br>or drag<br>a handle")
            }

            Behavior on scale {
                NumberAnimation {
                }

            }

        }

    }

    SequentialAnimation {
        id: hintAnim

        running: visible && runAnimOnce
        alwaysRunToEnd: true
        onStopped: runAnimOnce = false

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: tDial.showHint = true
        }

        SequentialAnimation {
            loops: 4

            NumberAnimation {
                target: tDial.handle
                property: "scale"
                to: 2
            }

            ScriptAction {
                script: tapRect.lighter = true
            }

            NumberAnimation {
                target: tDial.handle
                property: "scale"
                to: 1
            }

            ScriptAction {
                script: tapRect.lighter = false
            }

        }

        ScriptAction {
            script: tDial.showHint = Qt.binding(function() {
                return tDial.pressed;
            })
        }

    }

}
