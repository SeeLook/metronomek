/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
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
      anchors.verticalCenter: parent.verticalCenter
      leftPadding: fm.height
      text: dButt.text
      textFormat: Text.StyledText
      color: pressed ? activPal.highlightedText : activPal.text
    }

    Loader {
      active: dButt.checkable
      anchors { right: parent.right; verticalCenter: parent.verticalCenter }
      sourceComponent: Switch {
        id: stch
        checkable: true
        checked: dButt.checked
        indicator: Rectangle {
          implicitWidth: fm.height * 4; implicitHeight: fm.height / 3
          x: stch.leftPadding; y: (parent.height - height) / 2
          radius: height / 2
          color: stch.checked ? bgColor : activPal.base
          Behavior on color { ColorAnimation {} }

          Rectangle {
            x: stch.checked ? parent.width - width : 0; y: -height / 2 + parent.height / 2
            width: fm.height * 2; height: width; radius: width / 2
            color: bgColor
            Behavior on x { NumberAnimation {} }
            border {
              width: stch.checked ? 2 : fm.height / 2
              Behavior on width { NumberAnimation {} }
              color: stch.down ? activPal.base : activPal.button
            }
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
