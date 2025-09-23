/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Tdialog {
    id: vCntEdit

    // private
    property CountManager cntMan: SOUND.countManager()

    visible: true
    padding: GLOB.fontSize() / 2
    standardButtons: Dialog.RestoreDefaults | Dialog.Cancel | Dialog.Help
    Component.onCompleted: {
        (footer as DialogButtonBox).standardButton(Dialog.RestoreDefaults).text = qsTranslate("QPlatformTheme", "Save");
        (footer as DialogButtonBox).standardButton(Dialog.Help).text = GLOB.TR("TempoPage", "Actions");
        SOUND.initCountingSettings();
    }
    Component.onDestruction: {
        if (SOUND)
            SOUND.restoreAfterCountSettings();
    }
    onHelpRequested: moreMenu.open()
    onReset: {
        let cntPop = Qt.createComponent("Metronomek.Core", "CountingLangPop").createObject(mainWindow);
        (cntPop as Popup).closed.connect(function() {
            vCntEdit.close();
        });
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

            required property int index
            property alias spectrum: numSpec

            width: parent ? parent.width : 0
            height: FM.height * 5 + (ListView.isCurrentItem ? buttonsRect.height + FM.height / 3 : 0)
            color: Qt.tint(index % 2 ? ActivPalette.base : ActivPalette.alternateBase, GLOB.alpha(ActivPalette.highlight, ListView.isCurrentItem ? 20 : 0))

            NumeralSpectrum {
                id: numSpec

                nr: bgRect.index
                clip: true
                width: parent.width
                height: FM.height * 5
                Component.onCompleted: vCntEdit.cntMan.addSpectrum(numSpec)

                Text {
                    x: FM.height / 4
                    y: FM.height / 4
                    color: ListView.isCurrentItem ? ActivPalette.highlight : ActivPalette.text
                    text: bgRect.index + 1
                    style: Text.Outline
                    styleColor: ListView.isCurrentItem ? ActivPalette.text : bgRect.color

                    font {
                        pixelSize: parent.height * 0.25
                        bold: true
                    }

                }

                Rectangle {
                    id: playTick

                    width: FM.height / 4
                    height: parent.height
                    color: ActivPalette.highlight
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
                    onClicked: numList.currentIndex = bgRect.index
                }
            }

            Flow {
                id: buttonsRect

                scale: numList.currentIndex === bgRect.index ? 1 : 0
                transformOrigin: Item.Top
                spacing: bgRect.width * 0.01

                anchors {
                    top: bgRect.spectrum.bottom
                }

                CuteButton {
                    width: bgRect.width * 0.24
                    height: FM.height * 2
                    text: qsTranslate("QShortcut", "Play")
                    bgColor: Qt.tint(ActivPalette.button, GLOB.alpha("green", 40))
                    onClicked: {
                        playAnim.start();
                        vCntEdit.cntMan.play(bgRect.index);
                    }
                }

                CuteButton {
                    visible: !GLOB.isAndroid()
                    width: bgRect.width * 0.24
                    height: FM.height * 2
                    text: qsTr("Import")
                    bgColor: Qt.tint(ActivPalette.button, GLOB.alpha("blue", 40))
                    onClicked: vCntEdit.cntMan.getSingleWordFromFile(bgRect.index)
                }

                Item {
                    width: bgRect.width * (GLOB.isAndroid() ? 0.49 : 0.24)
                    height: FM.height * 2
                }

                CuteButton {
                    width: bgRect.width * 0.24
                    height: FM.height * 2
                    text: qsTr("Record")
                    bgColor: Qt.tint(ActivPalette.button, GLOB.alpha("red", 40))
                    onClicked: vCntEdit.cntMan.rec(bgRect.index)
                }

                Behavior on scale {
                    NumberAnimation {}
                }
            }

            Behavior on height {
                NumberAnimation {}
            }
        } // delegate
    }

    Menu {
        id: moreMenu

        y: vCntEdit.height - height - vCntEdit.implicitFooterHeight - vCntEdit.implicitHeaderHeight
        x: (vCntEdit.width - width) / 2
        Component.onCompleted: {
            if (!GLOB.isAndroid())
                moreMenu.insertItem(0, fromFileComp.createObject());

            var maxW = 0;
            for (var m = 0; m < count; ++m) maxW = Math.max(maxW, itemAt(m).width)
            width = Math.min(vCntEdit.width - FM.height * 3, maxW + 2 * FM.height);
        }

        MenuItem {
            text: qsTr("Align")
        }

        MenuItem {
            text: qsTranslate("QShortcut", "Help")
            onTriggered: {
                Qt.createComponent("Metronomek.Core", "HelpPop").createObject(mainWindow, {
                    "visible": true,
                    "helpText": "<b>" + GLOB.TR("VerbalCountPage", "Prepare own counting out loud") + ":</b>" + "<ul><li>" + qsTr("record every single numeral") + "</li><li>" + qsTr("or import wav file with it prepared in other software") + "</li><li>" + qsTr("or import wav file with all 12 numerals (Actions -> Load from file)") + "</li></ul><br><b>" + qsTr("CLUES") + ":</b>" + "<ul><li>" + qsTr("pronounce words quickly, not longer than 300 ms") + "</li><li>" + qsTr("accent one of the word syllables") + "</li><li>" + qsTr("imported wav files has to be 48000 Hz / 16 bit") + "</li></ul><br><a href=\"https://metronomek.sourceforge.io\">" + qsTr("Read more online.") + "</a>"
                });
            }
        }

    }

    Component {
        id: fromFileComp

        MenuItem {
            text: qsTr("Load from file")
            onTriggered: {
                vCntEdit.cntMan.getSoundFile();
            }
        }

    }

}
