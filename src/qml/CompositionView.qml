// SPDX-FileCopyrightText: 2021-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import Metronomek.Core
import QtQuick

pragma ComponentBehavior: Bound

Item {
    id: compView

    property MainWindow mainWindow: (Window.window as MainWindow)
    property Composition currComp: SOUND.speedHandler().currComp
    property var tp: mainWindow && currComp ? currComp.getPart(mainWindow.partId) : null
    property bool rall: tp && tp.initTempo > tp.targetTempo

    width: mainWindow.metroWidth
    height: mainWindow.height * 0.71
    x: mainWindow.width - width
    y: mainWindow.height * 0.05
    clip: true

    Text {
        parent: compView.mainWindow.pendulum
        rotation: compView.rall ? 180 : 0
        transformOrigin: Item.Center
        y: compView.tp && visible ? parent.height * 0.65 * ((compView.tp.targetTempo - 40) / 200) + (compView.rall ? height / 2 : parent.height * 0.18 - height / 2) : 0
        text: "\u00Be"
        color: ActivPalette.varTempo
        visible: compView.mainWindow.inMotion && compView.tp && compView.tp.initTempo !== compView.tp.targetTempo

        font {
            family: "Metronomek"
            pixelSize: parent.width
        }
    }

    Rectangle {
        z: 10
        x: partList.x - FM.height * 0.5
        y: partList.height / 4 - height
        visible: compView.mainWindow.inMotion
        color: ActivPalette.text
        width: partList.width * 2
        height: parent.height * 0.01
        radius: height / 2
    }

    ListView {
        id: partList

        x: parent.width - compView.mainWindow.metroWidth / 25
        width: compView.mainWindow.metroWidth / 30
        height: compView.mainWindow.height * 0.7
        model: compView.currComp?.partsCount
        currentIndex: compView.mainWindow.partId
        contentY: currentItem ? currentItem.y + ((currentItem as PartDelegate).tp.infinite ? currentItem.height / 2 
                                                                        : (compView.mainWindow.beatNr - 1) * (currentItem as PartDelegate).factor) - height / 4 : 0
        cacheBuffer: height

        delegate: PartDelegate {}
    }

    component PartDelegate : Rectangle {
        id: partDlg
        required property int index
        property TempoPart tp: compView.currComp ? compView.currComp.getPart(index) : null
        property real factor: {
            if (tp && tp.beats * GLOB.fontSize() < FM.height * 4)
                return (FM.height * 4) / tp.beats;
            else if (tp && tp.beats * GLOB.fontSize() > partList.height * 0.9)
                return (partList.height * 0.9) / tp.beats;
            else
                return GLOB.fontSize();
        }

        width: compView.mainWindow.metroWidth / 30
        height: (tp ? tp.beats : 1) * factor
        radius: width / 3
        color: Qt.lighter(ActivPalette.varTempo, index % 2 ? 0.8 : 1.2)

        Text {
            color: ActivPalette.text
            text: partDlg.tp ? partDlg.tp.initTempo : ""
            x: -width - GLOB.fontSize() / 2
            y: partDlg.tp && partDlg.tp.initTempo !== partDlg.tp.targetTempo ? 0 : (parent.height - height) / 2
        }

        Text {
            visible: partDlg.tp && partDlg.tp.initTempo !== partDlg.tp.targetTempo
            color: ActivPalette.text
            text: partDlg.tp && partDlg.tp.initTempo > partDlg.tp.targetTempo ? "rall." : "accel."
            x: -width - GLOB.fontSize() / 2
            y: FM.height * 2
            transformOrigin: Item.Right
            scale: visible && SOUND.playing && partDlg.index == compView.mainWindow.partId && compView.mainWindow.beatNr < 6 ? 3 : 1

            font {
                italic: true
                bold: true
            }

            Behavior on scale {
                NumberAnimation {
                }
            }
        }
    }

    TipRect {
        parent: Window.contentItem
        y: compView.mainWindow.inMotion && compView.tp && compView.tp.initTempo !== compView.tp.targetTempo ? -FM.height / 2 : -height - FM.height
        width: Math.min(Window.width, FM.height * 60)
        height: Window.height * 0.06
        x: (parent.width - width) / 2
        color: ActivPalette.varTempo
        radius: FM.height

        Text {
            x: (parent.width - width) / 2
            y: parent.height * 0.2
            transformOrigin: Item.Top
            color: ActivPalette.tempoText
            text: GLOB.TR("TtempoPart", compView.rall ? "rallentando" : "accelerando")
            style: Text.Outline
            styleColor: ActivPalette.base

            font {
                pixelSize: parent.height * 0.6
                italic: true
                bold: true
            }
        }

        Behavior on y {
            NumberAnimation {}
        }

    }

}
