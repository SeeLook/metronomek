/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Controls 2.12

Flickable {
  width: parent.width; height: parent.height
  clip: true
  ScrollBar.vertical: ScrollBar { active: true; visible: true }
  contentWidth: parent.width; contentHeight: drawCol.height

  Column {
    id: drawCol
    width: parent.width

    Logo { anim {running: drawer.visible; loops: 1 }}

    Rectangle {
      anchors { horizontalCenter: parent.horizontalCenter }
      width: parent.width - fm.height / 2; height: 1
      color: activPal.text
    }

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
            checkable: true
            checked: SOUND.beatType === index
          }
        }
      }
    }

    DrawerButton {
      text: qsTr("ring at \"one\"") + ":<br>&nbsp;&nbsp;&nbsp;&nbsp;<b> - " + SOUND.getRingName(SOUND.ringType) + "</b>"
      onClicked: ringMenu.popup()

      Menu {
        id: ringMenu
        Repeater {
          model: SOUND.ringTypeCount()
          MenuItem {
            text: SOUND.getRingName(index)
            onClicked: SOUND.ringType = index
            checkable: true
            checked: SOUND.ringType === index
          }
        }
      }
    }

    DrawerButton {
      text: qsTr("count down visible")
      checkable: true
      checked: GLOB.countVisible
      onToggled: GLOB.countVisible = checked
    }

    DrawerButton {
      text: qsTr("ring at \"one\"")
      checkable: true
      checked: SOUND.ring
      onToggled: SOUND.ring = checked
    }

    DrawerButton {
      text: qsTr("pendulum stationary")
      checkable: true
      checked: GLOB.stationary
      onToggled: GLOB.stationary = checked
    }

    DrawerButton {
      property var infoPage: null
      text: qsTr("about the app")
      onClicked: {
        if (!infoPage) {
          var p = Qt.createComponent("qrc:/InfoPage.qml")
          infoPage = p.createObject(mainWindow, { width: mainWindow.width, height: mainWindow.height })
        }
        infoPage.open()
        drawer.close()
      }
    }

    Item { // spacer
      width: parent.width; height: GLOB.fontSize() * 2
    }

    DrawerButton {
      text: qsTr("close app")
      onClicked: Qt.quit()
    }

  } // Column

}
