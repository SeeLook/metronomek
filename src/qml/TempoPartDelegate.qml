/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Rectangle {
  id: tpDelegate

  width: parent.width; height: tCol.height
  color: nr % 2 ? activPal.base : activPal.alternateBase

  property int nr: -1
  property TempoPart tp: null

  signal clicked()

  Column {
    id: tCol
    spacing: GLOB.fontSize() / 2
    padding: GLOB.fontSize() / 4
    width: parent.width - settBut.width - GLOB.fontSize()

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: tp.tempoText
      color: activPal.text
    }

    Text {
      text: qsTr("Duration") + ": " + qsTr("%n bar(s)", "", tp.bars) + ", " + qsTr("%n beat(s)", "", tp.beats)
                             + ", " + qsTr("%n second(s)", "", tp.seconds)
      color: activPal.text
    }
  }

  // private
  property real dotW: settBut.width / 3

  AbstractButton {
    id: settBut
    hoverEnabled: true
    anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: GLOB.fontSize() / 2 }
    width: GLOB.fontSize() * 2; height: GLOB.fontSize() * 5

    background: Rectangle {
      color: settBut.hovered ? activPal.highlight : activPal.button; radius: width / 4
    }

    contentItem: Item {
      property real dotW: settBut.width / 3
      Repeater {
        model: 3
        Rectangle {
          x: dotW; y: (settBut.height - 5 * dotW) / 2 + index * dotW * 2
          width: dotW; height: dotW; radius: dotW / 2
          color: settBut.pressed ? activPal.base : activPal.text
        }
      }
    }
    onClicked: tpDelegate.clicked()
  }
}
