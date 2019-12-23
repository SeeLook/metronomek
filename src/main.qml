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
  color: "#D1D1D1"

  TmetroItem {
    id: metro
    anchors.fill: parent

    Image {
      anchors.centerIn: parent
      source: "qrc:/bg.png"
      height: Math.min(parent.height, parent.width * 1.529564315352697)
      width: height * (sourceSize.width / sourceSize.height)

      Rectangle {
        id: pendulum
        color: "black"
        width: parent.width / 20; y: parent.height * 0.125 - width / 2 //0.4548
        x: parent.width * 0.3969; height: parent.height * 0.4572 //0,892
        radius: width / 2
        transformOrigin: Item.Bottom

        Shape {
          width: parent.width * 4; height: parent.height / 5
          y: parent.height * (0.05 + ((GLOB.tempo - 40) / 200) * 0.6)
          anchors.horizontalCenter: parent.horizontalCenter
          ShapePath {
            strokeWidth: pendulum.width / 2
            strokeColor: "black"
            fillColor: "gray"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: pendulum.width; startY: 0
            PathLine { x: pendulum.width * 3; y: 0 }
            PathLine { x: pendulum.width * 4; y: pendulum.height / 5 }
            PathLine { x: 0; y: pendulum.height / 5 }
            PathLine { x: pendulum.width; y: 0 }
          }
        }
      }

      Tumbler {
        id: tumb
        width: parent.width * 0.2; height: width 
        x: parent.width * 0.7 - width; y: parent.height * 0.83 - height
//         background: Rectangle { color: "white"; radius: width / 10 }
        model: 201
        wrap: false; visibleItemCount: 3
        currentIndex: GLOB.tempo - 40
//         onCurrentIndexChanged: GLOB.tempo = currentIndex + 40
        delegate:  Label {
          text: modelData + 40
          opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
          horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
          height: tumb.height / 3
          font { pixelSize: height * 0.9; bold: true }
          
        }
      }

      Slider {
        id: slider
        x: parent.width * 0.05; y: parent.height * 0.9 - height
        width: parent.width * 0.7
        from: 40; to: 240
        value: GLOB.tempo
        onMoved: GLOB.tempo = value
      }
    }
  }

  Connections {
    target: GLOB
    onTempoChanged: {
      anim.running = false
      anim.running = true
    }
  }

  property int aDur: (60000 / GLOB.tempo) / 2
  SequentialAnimation {
    id: anim
    running: true
    loops: Animation.Infinite
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
