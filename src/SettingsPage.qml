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
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: GLOB.fontSize()
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
    }
  }

  standardButtons: Dialog.Cancel | Dialog.Apply

  onApplied: {
    SOUND.setDeviceName(outCombo.currentText)
    close()
  }

  onVisibleChanged: {
    if (!visible)
      destroy()
  }
}

