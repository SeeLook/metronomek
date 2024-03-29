/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12

import Metronomek 1.0


Item {
  width: metro.width; height: mainWindow.height * 0.71
  x: mainWindow.width - width; y: mainWindow.height * 0.05
  clip: true

  property Composition currComp: SOUND.speedHandler().currComp
  property var tp: currComp.getPart(partId)
  property bool rall: tp && tp.initTempo > tp.targetTempo

  Text {
    parent: pendulum
    rotation: rall ? 180 : 0; transformOrigin: Item.Center
    y: tp && visible ? parent.height * 0.65 * ((tp.targetTempo - 40) / 200) + (rall ? height / 2 : parent.height * 0.18 - height / 2) : 0
    font { family: "Metronomek"; pixelSize: parent.width }
    text: "\u00Be"; color: activPal.varTempo
    visible: inMotion && tp && tp.initTempo !== tp.targetTempo
  }

  Rectangle {
    z: 10
    x: partList.x - fm.height * 0.5; y: partList.height / 4 - height
    visible: inMotion
    color: activPal.text; width: partList.width * 2; height: parent.height * 0.01; radius: height / 2
  }

  ListView {
    id: partList
    x: parent.width - metro.width / 25
    width: metro.width / 30; height: mainWindow.height * 0.7

    model: currComp.partsCount

    currentIndex: partId
    contentY: currentItem ? currentItem.y + (currentItem.tp.infinite ? currentItem.height / 2 : (beatNr - 1) * currentItem.factor) - height / 4 : 0
    cacheBuffer: height

    delegate: Rectangle {
      property TempoPart tp: currComp.getPart(index)
      property real factor: {
        if (tp && tp.beats * GLOB.fontSize() < fm.height * 4)
          return (fm.height * 4) / tp.beats
        else if (tp && tp.beats * GLOB.fontSize() > partList.height * 0.9)
          return (partList.height * 0.9) / tp.beats
        else
          return GLOB.fontSize()
      }
      width: metro.width / 30; height: (tp ? tp.beats : 1) * factor
      radius: width / 3
      color: Qt.lighter(activPal.varTempo, index % 2 ? 0.8 : 1.2)
      Text {
        color: activPal.text
        text: tp ? tp.initTempo : ""
        x: -width - GLOB.fontSize() / 2
        y: tp && tp.initTempo !== tp.targetTempo ? 0 : (parent.height - height) / 2
      }
      Text {
        visible: tp && tp.initTempo !== tp.targetTempo
        color: activPal.text
        text: tp && tp.initTempo > tp.targetTempo ? "rall." : "accel."
        font { italic: true; bold: true }
        x: -width - GLOB.fontSize() / 2; y: fm.height * 2
        transformOrigin: Item.Right
        scale: visible && SOUND.playing && index == partId && beatNr < 6 ? 3 : 1
        Behavior on scale { NumberAnimation {} }
      }
    } // delegate
  }

  TipRect {
    parent: mainWindow.contentItem
    y: inMotion && tp && tp.initTempo !== tp.targetTempo ? -fm.height / 2 : -height - fm.height
    Behavior on y { NumberAnimation{} }
    width: Math.min(mainWindow.width, fm.height * 60)
    height: mainWindow.height * 0.06
    x: (parent.width - width) / 2
    color: activPal.varTempo; radius: fm.height
    Text {
      x: (parent.width - width) / 2; y: parent.height * 0.2
      font { pixelSize: parent.height * 0.6; italic: true; bold: true }
      transformOrigin: Item.Top
      color: activPal.text
      text: GLOB.TR("TtempoPart", rall ? "rallentando" : "accelerando")
    }
  }
}
