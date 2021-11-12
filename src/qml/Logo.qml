/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12


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
        color: GLOB.randomColor(); style: Text.Raised
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
    color: activPal.text
    width: logo.height * 0.1; height: logo.height * 3
    radius: width / 2
    x: logo.width / 2 - width / 2
    transformOrigin: Item.Bottom
    rotation: -21
    Rectangle {
      color: parent.color
      height: parent.width * 2; width: parent.width * 3
      radius: height / 2
      anchors.horizontalCenter: parent.horizontalCenter
      y: height / 2
    }
  }

  SequentialAnimation {
    id: anim
    running: true
    loops: Animation.Infinite
    alwaysRunToEnd: true
    PauseAnimation { duration: pauseDuration }
    NumberAnimation { target: pendulum; property: "rotation"; to: -45; duration: 500 * (21 / 45) }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 45; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: 0; duration: 500 }
    NumberAnimation { target: pendulum; property: "rotation"; to: -21; duration: 500 * (21 / 45) }
  }
}
