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

    Button {
      text: "S"
      onClicked: tpDelegate.clicked()
    }
  }
}
