/** This file is part of Metronomek                                  *
 * Copyright (C) 2020 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


SpinBox {
  id: sb

  editable: false
  height: sb.font.pixelSize * 3; width: height * 3.5

  contentItem: Item {}

  background: Rectangle {
    color: activPal.base
    width: sb.width - 2 * sb.height; height: sb.height
    x: sb.height
    Label {
      text: sb.textFromValue(sb.value, sb.locale)
      anchors.centerIn: parent
      font { pixelSize: sb.height * 0.6; bold: true }
    }
  }

  up.indicator: TipRect {
    x: sb.mirrored ? 0 : sb.width - sb.height
    implicitHeight: sb.height; implicitWidth: sb.height
    color: activPal.button
    rised: !sb.up.pressed
    radius: sb.height / 4
    scale: sb.up.pressed ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 }}
    Rectangle {
      x: parent.width / 4; width: parent.width / 2; height: parent.height / 15; y: parent.height * 0.48
      color: activPal.text
    }
    Rectangle {
      x: parent.width / 4; width: parent.width / 2; height: parent.height / 15; y: parent.height * 0.48
      color: activPal.text
      rotation: 90
    }
  }

  down.indicator: TipRect {
    x: sb.mirrored ? sb.width - sb.height : 0
    implicitHeight: sb.height; implicitWidth: sb.height
    color: activPal.button
    rised: !sb.down.pressed
    radius: sb.height / 4
    scale: sb.down.pressed ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 }}
    Rectangle {
      x: parent.width / 4; width: parent.width / 2; height: parent.height / 15; y: parent.height * 0.48
      color: activPal.text
    }
  }
}
