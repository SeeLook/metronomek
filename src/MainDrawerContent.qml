/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


Column {
  width: parent.width
  spacing: 1

  Logo {}

  DrawerButton {
    text: qsTr("beat sound") + ":<br>&nbsp;&nbsp;&nbsp;&nbsp;<b> - " + SOUND.getBeatName(SOUND.beatType) + "</b>"
    onClicked: beatMenu.popup()

    Menu {
      id: beatMenu
      Repeater {
        model: SOUND.beatTypeCount()
        MenuItem {
          text: SOUND.getBeatName(index)
          onClicked: SOUND.beatType = index
        }
      }
    }
  }

}
