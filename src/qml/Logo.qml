/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Shapes 1.12


Rectangle {
  id: logo
  width: parent.width; height: width * 0.25
  color: activPal.window
  clip: true

  property alias anim: anim
  property int pauseDuration: 1000

  // private
  property real textW: 0
  property real initFontS: 0

  Component.onCompleted: initFontS = logo.height * 0.4

  Row {
    x: logo.width * 0.03
    // (logo.height * 0.4) / initFontS is a font size factor when logo size changes
    spacing: (logo.width * 0.9 - textW * ((logo.height * 0.4) / initFontS)) / 9
    Repeater {
      model: [ "M", "e", " ", "r", "o", "n", "o", "m", "e", "K" ]
      Text {
        y: GLOB.logoLetterY(index, logo.height * 1.5) - logo.height * 0.05
        rotation: -35 + index * (70 / 9)
        color: GLOB.randomColor(); style: Text.Raised; styleColor: activPal.shadow
        text: modelData
        font { pixelSize: logo.height * 0.4; bold: true }
        Component.onCompleted: textW += width
      }
    }
  }

  Text {
    anchors { top: parent.top; right: parent.right; margins: GLOB.isAndroid() ? 4 : 1 }
    text: GLOB.version()
    color: activPal.text
    font { pixelSize: logo.height * 0.2; bold: true }
    horizontalAlignment: Text.AlignHCenter
  }

  Text {
    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
    text: qsTr("The rhythmic<br>perfection")
    color: activPal.text
    font { pixelSize: logo.height * 0.14 }
    horizontalAlignment: Text.AlignHCenter
  }

  Rectangle {
    id: pendulum
    color: activPal.highlight
    width: logo.height * 0.1; height: logo.height * 3
    radius: width / 2
    x: logo.width / 2 - width / 2
    transformOrigin: Item.Bottom
    rotation: -20.5
    Shape {
      width: parent.width * 3; height: parent.width * 2
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height * (0.05 + ((-5) / 200) * 0.65)

      ShapePath {
        strokeWidth: pendulum.width / 3
        strokeColor: activPal.highlight
        fillColor: activPal.highlight
        capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
        startX: 0; startY: 0
        PathLine { x: pendulum.width * 3; y: 0 }
        PathLine { x: pendulum.width * 3; y: pendulum.width }
        PathLine { x: pendulum.width * 2.5; y: pendulum.width * 2 }
        PathLine { x: pendulum.width * 0.5; y: pendulum.width * 2 }
        PathLine { x: 0; y: pendulum.width }
        PathLine { x: 0; y: 0 }
      }
    }
  }

  SequentialAnimation {
    id: anim
    running: true
    loops: Animation.Infinite
    alwaysRunToEnd: true
    PauseAnimation { duration: pauseDuration }
    NumberAnimation { target: pendulum; property: "rotation"; to: -45; duration: 500 * (20.5 / 45) }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 45; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: -20.5; duration: 500 * (20.5 / 45) }
  }
}
