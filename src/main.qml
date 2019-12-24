/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12

import Metronomek 1.0

Window {
  visible: true
  width: GLOB.geometry.width
  height: GLOB.geometry.height
  x: GLOB.geometry.x ? GLOB.geometry.x : undefined
  y: GLOB.geometry.y ? GLOB.geometry.y : undefined
  title: qsTr("MetronomeK") + " v0.1"
  color: Qt.tint(activPal.base, GLOB.alpha(SOUND.playing ? "red" : "green", 10))

  SystemPalette { id: activPal;  colorGroup: SystemPalette.Active }

  TmetroItem {
//     id: metro
    anchors.fill: parent

    Image {
      id: metro
      anchors.centerIn: parent
      source: "qrc:/bg.png"
      height: Math.min(parent.height, parent.width * 1.529564315352697)
      width: height * (sourceSize.width / sourceSize.height)

      Rectangle {
        id: pendulum
        color: "black"
        width: parent.width / 20; y: parent.height * 0.125 - width / 2
        x: parent.width * 0.3969; height: parent.height * 0.4572
        radius: width / 2
        transformOrigin: Item.Bottom

        Shape {
          id: countW // counterweight
          width: parent.width * 4; height: parent.height / 5
          y: parent.height * (0.05 + ((GLOB.tempo - 40) / 200) * 0.6)
          anchors.horizontalCenter: parent.horizontalCenter
          ShapePath {
            strokeWidth: pendulum.width / 2
            strokeColor: countArea.containsPress ? activPal.highlight : "black"
            fillColor: "gray"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: pendulum.width; startY: 0
            PathLine { x: pendulum.width * 3; y: 0 }
            PathLine { x: pendulum.width * 4; y: pendulum.height / 5 }
            PathLine { x: 0; y: pendulum.height / 5 }
            PathLine { x: pendulum.width; y: 0 }
          }
          MouseArea {
            id: countArea
            anchors.fill: parent
            drag.target: countW
            drag.axis: Drag.YAxis
            drag.minimumY: pendulum.height * 0.05; drag.maximumY: pendulum.height * 0.65
            cursorShape: drag.active ? Qt.DragMoveCursor : Qt.ArrowCursor
            onPositionChanged: GLOB.tempo = Math.round((countW.y * 200) / (pendulum.height * 0.6) + 23)
          }
        }
      }

      SpinBox {
        id: sb
        height: parent.height * 0.07; width: height * 3
        x: parent.width * 0.7 - width; y: parent.height * 0.83 - height
        font { bold: true; }
        from: 40; to: 240
        value: GLOB.tempo
        onValueModified: GLOB.tempo = value
      }

      RoundButton {
        x: parent.width * 0.25 - width; y: parent.height * 0.5 + height
        width: parent.width * 0.15; height: width
        onClicked: SOUND.playing = !SOUND.playing
        Rectangle {
          width: parent.width * 0.6; height: width
          anchors.centerIn: parent
          radius: SOUND.playing ? 0 : width / 2
          color: SOUND.playing ? "red" : "green"
        }
      }
    }
  }

  Connections {
    target: GLOB
    onTempoChanged: {
      if (anim.running) {
        anim.running = false
        anim.running = true
      }
    }
  }

  property int aDur: (60000 / GLOB.tempo) / 2
  SequentialAnimation {
    id: anim
    running: SOUND.playing
    loops: Animation.Infinite
    alwaysRunToEnd: true
    NumberAnimation { target: pendulum; property: "rotation"; to: 35; duration: aDur }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: aDur }
    NumberAnimation { target: pendulum; property: "rotation"; to: -35; duration: aDur }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: aDur }
  }

  Component.onCompleted: {
    var t = GLOB.tempo
    GLOB.tempo = t -1
    GLOB.tempo = t
  }

  onClosing: {
    GLOB.geometry = Qt.rect(x ,y, width, height)
  }
}
