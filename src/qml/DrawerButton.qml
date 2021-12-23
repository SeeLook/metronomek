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
      sourceComponent: CheckBox {
        id: chB
        checkable: true
        checked: dButt.checked
        indicator: Text {
          font { family: "metronomek"; pixelSize: fm.height * 2 }
          x: chB.leftPadding; y: (parent.height - height) / 2
          color: bgColor
          text: "\u00A4"; style: Text.Raised; styleColor: activPal.shadow

          Text {
            anchors.centerIn: parent
            color: chB.checked ? activPal.text : activPal.base
            Behavior on color { ColorAnimation {} }
            font { family: "metronomek"; pixelSize: fm.height * 1.2 }
            text: "\u00A4"; style: Text.Sunken; styleColor: activPal.shadow
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
