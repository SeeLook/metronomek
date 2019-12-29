/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


AbstractButton {
  id: dButt
  width: parent.width; height: GLOB.fontSize() * 4

  background: Rectangle {
    color: pressed ? activPal.highlight : activPal.window
    
    Text {
      anchors.verticalCenter: parent.verticalCenter
      leftPadding: GLOB.fontSize()
      text: dButt.text
      textFormat: Text.StyledText
      color: activPal.text
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
  }
}
