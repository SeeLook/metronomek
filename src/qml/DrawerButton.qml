/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


AbstractButton {
  id: dButt
  implicitWidth: parent.width; implicitHeight: fm.height * 2.4

  property color bgColor: activPal.window

  background: Rectangle {
    color: pressed ? activPal.highlight : activPal.window //Qt.tint(activPal.window, GLOB.alpha(bgColor, 40))

    Text {
      width: parent.width - (dButt.checkable ? chLoader.item.width : 0)
      anchors.verticalCenter: parent.verticalCenter
      leftPadding: fm.height
      text: dButt.text
      font.pixelSize: fm.height * 0.9
      minimumPixelSize: fm.height / 2; fontSizeMode: Text.Fit
      textFormat: Text.StyledText
      elide: Text.ElideRight
      color: pressed ? activPal.highlightedText : activPal.text
    }

    Loader {
      id: chLoader
      active: dButt.checkable
      anchors { right: parent.right; verticalCenter: parent.verticalCenter }
      sourceComponent: CheckBox {
        id: chB
        checkable: true
        checked: dButt.checked
        scale: pressed ? 0.8 : 1
        Behavior on scale { NumberAnimation {} }
        indicator: TipRect {
          color: bgColor
          x: chB.leftPadding; y: (parent.height - height) / 2
          width: fm.height * 1.6; height: width
          Rectangle {
            anchors.centerIn: parent
            border { width: chB.checked ? 0 : 1; color: Qt.darker(bgColor, 1.3) }
            width: parent.width * 0.6; height: width; radius: width / 8
            color: chB.checked ? bgColor : activPal.base
            Behavior on color { ColorAnimation {} }
          }
        }
        onToggled: {
          dButt.toggle()
          dButt.toggled()
        }
      }
    }
    Rectangle {
      anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
      width: parent.width - fm.height / 2; height: 1
      color: activPal.text
    }
  }
}
