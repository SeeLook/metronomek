/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
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
      text: qsTr("beat sound") + ":<br>&nbsp;<b> - "
          + (SOUND.verbalCount ? qsTr("Verbal count") : SOUND.getBeatName(SOUND.beatType)) + "</b>"
      onClicked: beatMenu.popup()
      onPressAndHold: {
        Qt.createComponent("qrc:/VerbalCountPage.qml").createObject(mainWindow)
        drawer.close()
      }
      Menu {
        id: beatMenu
        parent: mainWindow.contentItem
        width: Math.min(drawCol.width, fm.height * 20)
        Repeater {
          model: SOUND.beatTypeCount() + 1
          MenuItem {
            text: index ? SOUND.getBeatName(index - 1) : qsTr("Verbal count")
            onClicked: {
              if (index)
                SOUND.beatType = index - 1
              SOUND.verbalCount = index === 0
            }
            checkable: true
            checked: SOUND.verbalCount ? index === 0 : SOUND.beatType === index - 1
          }
        }
      }
    }

    DrawerButton {
      text: qsTr("ring at \"one\"") + ":<br>&nbsp;<b> - " + SOUND.getRingName(SOUND.ringType) + "</b>"
      onClicked: ringMenu.popup()

      Menu {
        id: ringMenu
        parent: mainWindow.contentItem
        width: Math.min(drawCol.width, fm.height * 20)
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
      text: qsTr("ring at \"one\"")
      bgColor: "red"
      checkable: true
      checked: SOUND.ring
      onToggled: SOUND.ring = checked
    }

    DrawerButton {
      text: qsTr("count down visible")
      bgColor: "yellow"
      checkable: true
      checked: GLOB.countVisible
      onToggled: GLOB.countVisible = checked
    }

    DrawerButton {
      text: qsTr("pendulum stationary")
      bgColor: "lime"
      checkable: true
      checked: GLOB.stationary
      onToggled: GLOB.stationary = checked
    }

    DrawerButton {
      text: GLOB.TR("MainWindow", "Tempo changes").toLowerCase()
      bgColor: activPal.varTempo
      checkable: true
      checked: SOUND.variableTempo
      onToggled: {
        SOUND.variableTempo = checked
        if (checked) {
          Qt.createComponent("qrc:/TempoPage.qml").createObject(mainWindow)
          drawer.close()
        }
      }
    }

    DrawerButton {
      text: qsTr("settings")
      onClicked: {
        Qt.createComponent("qrc:/SettingsPage.qml").createObject(mainWindow)
        drawer.close()
      }
    }

    DrawerButton {
      property var infoPage: null
      text: qsTr("about the app")
      onClicked: {
        if (!infoPage)
          infoPage = Qt.createComponent("qrc:/InfoPage.qml").createObject(mainWindow)

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
