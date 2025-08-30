/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek
import Metronomek.Core
import QtQuick
import QtQuick.Controls

Tdialog {
    id: vCntEdit

    // private
    property CountManager cntMan: SOUND.countManager()

    visible: true
    padding: GLOB.fontSize() / 2
    standardButtons: Dialog.RestoreDefaults | Dialog.Cancel | Dialog.Help
    Component.onCompleted: {
        footer.standardButton(Dialog.RestoreDefaults).text = qsTranslate("QPlatformTheme", "Save");
        footer.standardButton(Dialog.Help).text = GLOB.TR("TempoPage", "Actions");
        SOUND.initCountingSettings();
    }
    Component.onDestruction: {
        SOUND.restoreAfterCountSettings();
    }
    onHelpRequested: moreMenu.open()
    onReset: {
        Qt.createComponent("Metronomek.Core", "CountingLangPop").createObject(mainWindow);
    }

    ListView {
        id: numList

        currentIndex: -1
        model: 12
        width: parent ? parent.width : 0
        height: parent ? parent.height : 0
        spacing: 1

        delegate: Rectangle {
            id: bgRect

            property alias spectrum: numSpec

            width: parent ? parent.width : 0
            height: fm.height * 5 + (numList.currentIndex === index ? buttonsRect.height + fm.height / 3 : 0)
            color: Qt.tint(index % 2 ? activPal.base : activPal.alternateBase, GLOB.alpha(activPal.highlight, numList.currentIndex === index ? 20 : 0))

            NumeralSpectrum {
                id: numSpec

                nr: index
                clip: true
                width: parent.width
                height: fm.height * 5
                Component.onCompleted: cntMan.addSpectrum(numSpec)

                Text {
                    x: fm.height / 4
                    y: fm.height / 4
                    color: numList.currentIndex === index ? activPal.highlight : activPal.text
                    text: index + 1
                    style: Text.Outline
                    styleColor: numList.currentIndex === index ? activPal.text : bgRect.color

                    font {
                        pixelSize: parent.height * 0.25
                        bold: true
                    }

                }

                Rectangle {
                    id: playTick

                    width: fm.height / 4
                    height: parent.height
                    color: activPal.highlight
                    visible: playAnim.running
                }

                Text {
                    text: numSpec.recMessage
                    anchors.centerIn: parent
                    color: "red"
                    style: Text.Outline
                    styleColor: bgRect.color

                    font {
                        pixelSize: parent.height / 3
                        bold: true
                    }

                }

                NumberAnimation {
                    id: playAnim

                    target: playTick
                    property: "x"
                    duration: 750
                    from: 0
                    to: numSpec.width
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: numList.currentIndex = index
                }

            }

            Flow {
                id: buttonsRect

                scale: numList.currentIndex === index ? 1 : 0
                transformOrigin: Item.Top
                spacing: bgRect.width * 0.01

                anchors {
                    top: spectrum.bottom
                }

                CuteButton {
                    width: bgRect.width * 0.24
                    height: fm.height * 2
                    text: qsTranslate("QShortcut", "Play")
                    bgColor: Qt.tint(activPal.button, GLOB.alpha("green", 40))
                    onClicked: {
                        playAnim.start();
                        cntMan.play(index);
                    }
                }

                CuteButton {
                    visible: !GLOB.isAndroid()
                    width: bgRect.width * 0.24
                    height: fm.height * 2
                    text: qsTr("Import")
                    bgColor: Qt.tint(activPal.button, GLOB.alpha("blue", 40))
                    onClicked: cntMan.getSingleWordFromFile(index)
                }

                Item {
                    width: bgRect.width * (GLOB.isAndroid() ? 0.49 : 0.24)
                    height: fm.height * 2
                }

                CuteButton {
                    width: bgRect.width * 0.24
                    height: fm.height * 2
                    text: qsTr("Record")
                    bgColor: Qt.tint(activPal.button, GLOB.alpha("red", 40))
                    onClicked: cntMan.rec(index)
                }

                Behavior on scale {
                    NumberAnimation {
                    }

                }

            }

            Behavior on height {
                NumberAnimation {
                }

            }

        }

    }

    Menu {
        id: moreMenu

        y: vCntEdit.height - height - vCntEdit.implicitFooterHeight - vCntEdit.implicitHeaderHeight
        x: (vCntPage.width - width) / 2
        Component.onCompleted: {
            if (!GLOB.isAndroid())
                moreMenu.insertItem(0, fromFileComp.createObject());

            var maxW = 0;
            for (var m = 0; m < count; ++m) maxW = Math.max(maxW, itemAt(m).width)
            width = Math.min(vCntEdit.width - fm.height * 3, maxW + 2 * fm.height);
        }

        MenuItem {
            text: qsTr("Align")
        }

        MenuItem {
            text: qsTranslate("QShortcut", "Help")
            onTriggered: {
                Qt.createComponent("Metronomek.Core", "HelpPop").createObject(mainWindow, {
                    "visible": true,
                    "helpText": "<b>" + GLOB.TR("VerbalCountPage", "Prepare own verbal counting") + ":</b>" + "<ul><li>" + qsTr("record every single numeral") + "</li><li>" + qsTr("or import wav file with it prepared in other software") + "</li><li>" + qsTr("or import wav file with all 12 numerals (Actions -> Load from file)") + "</li></ul><br><b>" + qsTr("CLUES") + ":</b>" + "<ul><li>" + qsTr("pronounce words quickly, not longer than 300 ms") + "</li><li>" + qsTr("accent one of the word syllables") + "</li><li>" + qsTr("imported wav files has to be 48000 Hz / 16 bit") + "</li></ul><br><a href=\"https://metronomek.sourceforge.io\">" + qsTr("Read more online.") + "</a>"
                });
            }
        }

    }

    Component {
        id: fromFileComp

        MenuItem {
            text: qsTr("Load from file")
            onTriggered: {
                cntMan.getSoundFile();
            }
        }

    }

}
