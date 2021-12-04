/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
//import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12

import Metronomek 1.0


Item {
  width: metro.width; height: mainWindow.height * 0.72
  x: mainWindow.width - width; y: mainWindow.height * 0.05
  clip: true

  property Composition currComp: SOUND.speedHandler().currComp

  Rectangle {
    z: 10
    x: partList.x - fm.height * 0.5; y: partList.height / 4 - height
    visible: SOUND.playing
    color: activPal.text; width: fm.height * 3; height: fm.height / 2; radius: height / 2
  }

  ListView {
    id: partList
    x: parent.width - metro.width / 16
    width: metro.width / 20; height: mainWindow.height * 0.7

    model: currComp.partsCount()

    currentIndex: partId
    contentY: SOUND.playing && currentItem ? currentItem.y + (beatNr - 1) * currentItem.factor - height / 4 : 0
    cacheBuffer: height

    delegate: Rectangle {
      property TempoPart tp: currComp.getPart(index)
      property real factor: {
        if (tp.beats * GLOB.fontSize() < fm.height * 4)
          return (fm.height * 4) / tp.beats
        else if (tp.beats * GLOB.fontSize() > partList.height)
          return partList.height / tp.beats
        else
          return GLOB.fontSize()
      }
      width: metro.width / 20; height: tp.beats * factor
      radius: width / 3
      color: Qt.lighter("skyBlue", index % 2 ? 0.8 : 1.2)
      Text {
        color: activPal.text
        text: tp.initTempo
        x: -width - GLOB.fontSize() / 2
        y: tp.initTempo !== tp.targetTempo ? 0 : (parent.height - height) / 2
      }
      Text {
        visible: tp.initTempo !== tp.targetTempo
        color: activPal.text
        text: tp.initTempo > tp.targetTempo ? "rall." : "accel."
        x: -width - GLOB.fontSize() / 2; y: fm.height * 2 //parent.height - height - GLOB.fontSize() / 2
        transformOrigin: Item.Right
        scale: visible && SOUND.playing && index == partId && beatNr < 4 ? 3 : 1
        Behavior on scale { NumberAnimation {} }
      }
    } // delegate

  }
}
