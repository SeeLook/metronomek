/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Rectangle {
  id: tpDelegate

  width: parent ? parent.width : 0; height: tCol ? tCol.height : 0
  color: ma.pressed || ma.containsMouse ? Qt.tint(activPal.base, GLOB.alpha(toDel ? "red": activPal.highlight, 50))
                                        : (nr % 2 ? activPal.base : activPal.alternateBase)

  property TempoPart tp: null
  property int nr: tp ? tp.nr + 1 : -1
  property bool toDel: Math.abs(x) > delText.width

  signal clicked()

  Column {
    id: tCol
    spacing: GLOB.fontSize() / 2
    padding: GLOB.fontSize() / 4
    width: parent.width - GLOB.fontSize()

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
    id: delText
    visible: toDel
    parent: tpDelegate.parent
    text: qsTranslate("QLineEdit", "Delete")
    y: tpDelegate.y + (tpDelegate.height - height) / 2
    x: tpDelegate.x > delText.width ? fm.height : tpDelegate.width - fm.height - width
    color: "red"; font.bold: true
  }

  // private
  property bool wasDragged: false
  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: !GLOB.isAndroid()
    drag.axis: Drag.XAxis
    drag.minimumX: -width / 3; drag.maximumX: width / 3
    drag.target: tempoModel.count > 1 ? parent : null
    onPressed: wasDragged = false
    onPositionChanged: {
      if (Math.abs(tpDelegate.x) > fm.height)
        wasDragged = true
    }
    onReleased: {
      if (Math.abs(tpDelegate.x) > delText.width + fm.height) {
          rmAnim.to = tpDelegate.x > 0 ? tpDelegate.width : -tpDelegate.width
          rmAnim.start()
      } else {
          backAnim.start()
          if (!wasDragged && Math.abs(tpDelegate.x) < fm.height)
            tpDelegate.clicked()
      }
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
    onFinished: speedHandler.removeTempo(tp.nr - 1)
  }
}
