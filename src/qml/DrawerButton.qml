/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


AbstractButton {
  id: dButt
  width: parent.width; height: fm.height * 2.4

  background: Rectangle {
    color: pressed ? activPal.highlight : activPal.window

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
        checkable: true
        checked: dButt.checked
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
