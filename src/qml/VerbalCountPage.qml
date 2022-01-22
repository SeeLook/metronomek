/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Tdialog {
  id: vCntPage

  visible: true
  padding: GLOB.fontSize() / 2

  ButtonGroup { id: soundsGr }

  // private
  property CountImport cntImport: SOUND.countImport()

  header: Column {
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      color: activPal.text
      text: qsTr("sounds of counting")
    }
    Row {
      spacing: fm.height
      anchors.horizontalCenter: parent.horizontalCenter
      RadioButton {
        id: builtRadio
        text: qsTr("built-in")
        ButtonGroup.group: soundsGr
        onToggled: stack.replace(builtComp)
      }
      RadioButton {
        id: customRadio
        checked: true
        text: qsTr("custom")
        ButtonGroup.group: soundsGr
        onToggled: stack.replace(customComp)
      }
    }
  }

  StackView {
    id: stack
    width: parent.width; height: parent.height
    initialItem: customComp
    replaceEnter: Transition { NumberAnimation { property: "x"; from: -width; to: 0 }}
    replaceExit: Transition { NumberAnimation { property: "x"; from: 0; to: width }}
    clip: true
  }

  Component {
    id: customComp
    ListView {
      id: numList
      model: 12

      width: parent ? parent.width : 0; height: parent ? parent.height : 0
      spacing: 1
      delegate: Rectangle {
        id: bgRect
        width: parent ? parent.width : 0; height: fm.height * 5
        color: index % 2 ? activPal.base : activPal.alternateBase
        Row {
          anchors.verticalCenter: parent.verticalCenter
          spacing: fm.height
          x: fm.height / 2
          AbstractButton {
            id: playButt
            anchors.verticalCenter: parent.verticalCenter
            height: fm.height * 3; width: height
            background: TipRect { radius: width / 2; raised: !parent.pressed }
            indicator: Text {
              x: (parent.width - width) / 2 + width / 8; y: (parent.height - height) / 2
              text: "\u00bf"
              color: "green"; style: Text.Raised; styleColor: activPal.shadow
              font { family: "Metronomek"; pixelSize: playButt.height * 0.7 }
              Text {
                x: parent.height / 8; y: (parent.height - height) / 2
                color: "white"; text: index + 1
                font { pixelSize: parent.height * 0.3; bold: true }
              }
            }
            onClicked: {
              playAnim.start()
              cntImport.play(index)
            }
          }
          NumeralSpectrum {
            nr: index
            clip: true
            width: numList.width - playButt.width - recButt.width - 3 * fm.height; height: bgRect.height
            Rectangle {
              id: playTick
              width: fm.height / 4; height: parent.height
              color: activPal.highlight
              visible: playAnim.running
            }
            NumberAnimation {
              id: playAnim
              target: playTick; property: "x"
              duration: 750
              from: 0; to: parent.width
            }
          }
          AbstractButton {
            id: recButt
            anchors.verticalCenter: parent.verticalCenter
            height: fm.height * 3; width: height
            background: TipRect { radius: width / 2; raised: !parent.pressed }
            indicator: Text {
              x: (parent.width - width) / 2; y: (parent.height - height) / 2
              text: "\u00c0"
              color: "red"; style: Text.Raised; styleColor: activPal.shadow
              font { family: "Metronomek"; pixelSize: recButt.height * 0.5 }
            }
          }
        }
      }
    }
  }

  Component {
    id: builtComp
    Column {
      RadioButton {
        text: "something"
      }
    }
  }

  standardButtons: Dialog.Ok | Dialog.Cancel
  Component.onCompleted: {
    //footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "Save")
    SOUND.initCountingSettings()
  }
  Component.onDestruction: {
    SOUND.restoreAfterCountSettings()
  }
}
