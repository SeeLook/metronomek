/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Shapes 1.12

import Metronomek 1.0

Window {
  visible: true
  height: 480; width: 314
  title: qsTr("MetronomeK") + " v0.1"

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
          y: parent.height * 0.1
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
    }
  }

  SequentialAnimation {
    running: true
    loops: Animation.Infinite
    NumberAnimation { target: pendulum; property: "rotation"; to: 35; duration: 250 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 250 }
    NumberAnimation { target: pendulum; property: "rotation"; to: -35; duration: 250 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 250 }
  }
}
