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

  property bool leanEnough: false // pendulum is leaned out enough to start playing

  TmetroItem {
//     id: metro
    anchors.fill: parent

    Image {
      id: metro
      anchors.centerIn: parent
      source: "qrc:/bg.png"
      height: Math.min(parent.height, parent.width * 1.529564315352697)
      width: height * (sourceSize.width / sourceSize.height)

      MouseArea {
        id: stopArea
        enabled: SOUND.playing
        width: parent.width; height: parent.height * 0.5
        onPressAndHold: SOUND.playing = false
      }

      Rectangle {
        id: pendulum
        color: leanEnough ? "green" : (stopArea.containsPress ? "red" : (pendArea.dragged ? activPal.highlight : "black"))
        width: parent.width / 20; y: parent.height * 0.125 - width / 2
        x: parent.width * 0.3969; height: parent.height * 0.4572
        radius: width / 2
        transformOrigin: Item.Bottom

        MouseArea {
          id: pendArea
          property bool dragged: false
          enabled: !SOUND.playing
          anchors.fill: parent
          cursorShape: dragged ? Qt.DragMoveCursor : Qt.ArrowCursor
          onPositionChanged: {
            dragged = true
            var dev = mouse.x - width / 2
            pendulum.rotation = (Math.atan(dev / height) * 180) / Math.PI
            leanEnough = Math.abs(dev) > height * 0.268 // 15 deg
          }
          onReleased: {
            leanEnough = false
            dragged = false
            if (Math.abs(mouse.x - width / 2) > height * 0.268)
              SOUND.playing = true
            else
              pendulum.rotation = 0
          }
        }

        Shape {
          id: countW // counterweight
          width: parent.width * 3; height: parent.height / 5
          y: parent.height * (0.05 + ((GLOB.tempo - 40) / 200) * 0.6)
          anchors.horizontalCenter: parent.horizontalCenter
          ShapePath {
            strokeWidth: pendulum.width / 3
            strokeColor: countArea.containsPress ? activPal.highlight : "black"
            fillColor: "gold"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: 0; startY: 0
            PathLine { x: pendulum.width * 3; y: 0 }
            PathLine { x: pendulum.width * 3; y: pendulum.height / 5 }
            PathLine { x: pendulum.width * 2.5; y: pendulum.height / 4.2 }
            PathLine { x: pendulum.width * 0.5; y: pendulum.height / 4.2 }
            PathLine { x: 0; y: pendulum.height / 5 }
            PathLine { x: 0; y: 0 }
          }
          MouseArea {
            id: countArea
            enabled: !SOUND.playing
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
    }
  }

  RoundButton {
    anchors { right: parent.right; top: parent.top; margins: parent.width / 50 }
    width: metro.width * 0.2; height: width / 2
    radius: width / 6
    onClicked: SOUND.playing = !SOUND.playing
    Rectangle {
      width: parent.height * 0.6; height: width
      anchors.centerIn: parent
      radius: SOUND.playing ? 0 : width / 2
      color: SOUND.playing ? "red" : "green"
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

//   Component.onCompleted: {}

  onClosing: {
    GLOB.geometry = Qt.rect(x ,y, width, height)
  }
}
