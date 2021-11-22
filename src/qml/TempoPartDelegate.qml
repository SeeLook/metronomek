/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Rectangle {
  id: tpDelegate

  width: parent ? parent.width : 0; height: tCol ? tCol.height : 0
  color: nr % 2 ? activPal.base : activPal.alternateBase

  property TempoPart tp: null
  property int nr: tp ? tp.nr + 1 : -1

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
      //anchors.horizontalCenter: parent.horizontalCenter
      text: GLOB.TR("TempoPage", "Meter") + " (" + GLOB.TR("MainWindow", "count to") + "): " + tp.meter
      color: activPal.text
    }

    Text {
      text: GLOB.TR("TempoPage", "Duration") + ": " + (tp.infinite ? GLOB.TR("TempoPage", "infinite")
                                                                   : qsTr("%n bar(s)", "", tp.bars)
                                                           + " = " + qsTr("%n beat(s)", "", tp.beats)
                                                           + " = " + qsTr("%n second(s)", "", tp.seconds))
      color: activPal.text
    }
  }

  Text {
    id: trash
    visible: false
    parent: tpDelegate.parent
    text: qsTranslate("QLineEdit", "Delete")
    y: tpDelegate.y + (tpDelegate.height - height) / 2
    x: tpDelegate.x > tpDelegate.width / 4 ? fm.height : tpDelegate.width - fm.height - width
    color: "red"; font.bold: true
  }

  MouseArea {
    id: dragArea
    anchors.fill: parent
    drag.axis: Drag.XAxis
    drag.minimumX: -width / 3; drag.maximumX: width / 3
    drag.target: parent
    onPositionChanged: {
        trash.visible = Math.abs(tpDelegate.x) > width / 4
    }
    onReleased: {
      if (Math.abs(tpDelegate.x) > width / 4) {
          rmAnim.to = tpDelegate.x > 0 ? tpDelegate.width : -tpDelegate.width
          rmAnim.start()
      } else
          backAnim.start()
    }
  }

  NumberAnimation {
    id: backAnim
    target: tpDelegate; property: "x"
    to: 0
  }

  NumberAnimation {
    id: rmAnim
    target: tpDelegate; property: "x"
    onFinished: speedHandler.remove(tp.nr - 1)
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
