/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick

Item {
    property Composition currComp: SOUND.speedHandler().currComp
    property var tp: mainWindow && currComp ? currComp.getPart(partId) : null
    property bool rall: tp && tp.initTempo > tp.targetTempo

    width: metro.width
    height: mainWindow.height * 0.71
    x: mainWindow.width - width
    y: mainWindow.height * 0.05
    clip: true

    Text {
        parent: pendulum
        rotation: rall ? 180 : 0
        transformOrigin: Item.Center
        y: tp && visible ? parent.height * 0.65 * ((tp.targetTempo - 40) / 200) + (rall ? height / 2 : parent.height * 0.18 - height / 2) : 0
        text: "\u00Be"
        color: ActivPalette.varTempo
        visible: inMotion && tp && tp.initTempo !== tp.targetTempo

        font {
            family: "Metronomek"
            pixelSize: parent.width
        }

    }

    Rectangle {
        z: 10
        x: partList.x - FM.height * 0.5
        y: partList.height / 4 - height
        visible: inMotion
        color: ActivPalette.text
        width: partList.width * 2
        height: parent.height * 0.01
        radius: height / 2
    }

    ListView {
        id: partList

        x: parent.width - metro.width / 25
        width: metro.width / 30
        height: mainWindow.height * 0.7
        model: currComp?.partsCount
        currentIndex: partId
        contentY: currentItem ? currentItem.y + (currentItem.tp.infinite ? currentItem.height / 2 : (beatNr - 1) * currentItem.factor) - height / 4 : 0
        cacheBuffer: height

        delegate: Rectangle {
            property TempoPart tp: currComp ? currComp.getPart(index) : null
            property real factor: {
                if (tp && tp.beats * GLOB.fontSize() < FM.height * 4)
                    return (FM.height * 4) / tp.beats;
                else if (tp && tp.beats * GLOB.fontSize() > partList.height * 0.9)
                    return (partList.height * 0.9) / tp.beats;
                else
                    return GLOB.fontSize();
            }

            width: metro.width / 30
            height: (tp ? tp.beats : 1) * factor
            radius: width / 3
            color: Qt.lighter(ActivPalette.varTempo, index % 2 ? 0.8 : 1.2)

            Text {
                color: ActivPalette.text
                text: tp ? tp.initTempo : ""
                x: -width - GLOB.fontSize() / 2
                y: tp && tp.initTempo !== tp.targetTempo ? 0 : (parent.height - height) / 2
            }

            Text {
                visible: tp && tp.initTempo !== tp.targetTempo
                color: ActivPalette.text
                text: tp && tp.initTempo > tp.targetTempo ? "rall." : "accel."
                x: -width - GLOB.fontSize() / 2
                y: FM.height * 2
                transformOrigin: Item.Right
                scale: visible && SOUND.playing && index == partId && beatNr < 6 ? 3 : 1

                font {
                    italic: true
                    bold: true
                }

                Behavior on scale {
                    NumberAnimation {
                    }

                }

            }
            // delegate

        }

    }

    TipRect {
        parent: mainWindow.contentItem
        y: inMotion && tp && tp.initTempo !== tp.targetTempo ? -FM.height / 2 : -height - FM.height
        width: Math.min(mainWindow.width, FM.height * 60)
        height: mainWindow.height * 0.06
        x: (parent.width - width) / 2
        color: ActivPalette.varTempo
        radius: FM.height

        Text {
            x: (parent.width - width) / 2
            y: parent.height * 0.2
            transformOrigin: Item.Top
            color: ActivPalette.text
            text: GLOB.TR("TtempoPart", rall ? "rallentando" : "accelerando")

            font {
                pixelSize: parent.height * 0.6
                italic: true
                bold: true
            }

        }

        Behavior on y {
            NumberAnimation {
            }

        }

    }

}
