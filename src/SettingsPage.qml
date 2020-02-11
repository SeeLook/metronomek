/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
  id: settPage
  visible: true

  Flickable {
    width: parent.width; height: parent.height
    clip: true
    ScrollBar.vertical: ScrollBar { active: true; visible: true }
    contentWidth: parent.width; contentHeight: col.height

    Column {
      id: col
      width: parent.width
      spacing: GLOB.fontSize()

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: GLOB.fontSize()
        visible: outCombo.count > 1 // only when there are more devices to choose
        Label {
          id: sndLabel
          anchors.verticalCenter: parent.verticalCenter
          text: qsTr("Sound device").replace(" ", "<br>")
          textFormat: Text.StyledText
        }
        ComboBox {
          id: outCombo
          anchors.verticalCenter: parent.verticalCenter
          width: settPage.contentItem.width - sndLabel.width - GLOB.fontSize() * 2
          model: SOUND.getAudioDevicesList()
          Component.onCompleted: {
            outCombo.currentIndex = outCombo.find(SOUND.outputName())
          }
        }
      }

      Loader {
        id: andSettLoader
        sourceComponent: GLOB.isAndroid() ? andSettComp : undefined
        anchors.horizontalCenter: parent.horizontalCenter
      }

    } // Column
  } // Flickable

  standardButtons: Dialog.Cancel | Dialog.Apply

  onApplied: {
    if (outCombo.count > 1)
      SOUND.setDeviceName(outCombo.currentText)
    if (GLOB.isAndroid()) {
      GLOB.keepScreenOn(andSettLoader.item.scrOn)
      GLOB.setDisableRotation(andSettLoader.item.noRotation)
      mainWindow.visibility = andSettLoader.item.fullScr ? "FullScreen" : "AutomaticVisibility"
      GLOB.setFullScreen(andSettLoader.item.fullScr)
    }
    close()
  }

  onVisibleChanged: {
    if (!visible)
      destroy()
  }

  Component {
    id: andSettComp
    Column {
      property alias scrOn: screenOnChB.checked
      property alias noRotation: disRotatChB.checked
      property alias fullScr: fullScrChB.checked
      spacing: GLOB.fontSize() / 2
      CheckBox {
        id: screenOnChB
        text: qsTr("keep screen on")
        checked: GLOB.isKeepScreenOn()
      }
      CheckBox {
        id: disRotatChB
        text: qsTr("disable screen rotation")
        checked: GLOB.disableRotation()
      }
      CheckBox {
        id: fullScrChB
        text: qsTr("use full screen")
        checked: GLOB.fullScreen()
      }
    }
  }
}

