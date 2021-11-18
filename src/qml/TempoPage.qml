/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Tdialog {
  id: tempoPage

  // private
  property SpeedHandler speedHandler: null

  visible: true
  topPadding: 0; bottomPadding: GLOB.fontSize() / 2

  ListModel { id: tempoModel }

  ListView {
    width: parent.width; height: parent.height
    spacing: 1

    header: TextField {
      width: parent.width
      placeholderText: qsTr("Name of rhythm piece")
      selectByMouse: true
    }

    model: tempoModel

    delegate: TempoPartDelegate {
      nr: index + 1
      tp: modelData
      onClicked: {
        pop.tp = tp
        pop.open()
      }
    }

    footer: Button {
      width: parent.width
      text: qsTr("Add tempo change")
      onClicked: speedHandler.add()
    }
  }

  standardButtons: Dialog.Ok

  Component.onCompleted: {
    mainWindow.dialogItem = tempoPage
    footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK")
    speedHandler = SOUND.speedHandler()
    speedHandler.emitAllTempos()
  }

  Connections {
    target: speedHandler
    onAppendTempoChange: tempoModel.append( {"tempoPart": tp} )
  }

  Popup {
    id: pop

    scale: 0
    enter: Transition { NumberAnimation { property: "scale"; to: 1.0 }}
    exit: Transition { NumberAnimation { property: "scale"; to: 0 }}

    property TempoPart tp: null

    Column {
      id: tCol
      spacing: GLOB.fontSize() / 2
      padding: GLOB.fontSize() / 4

      Text {
        text: pop.tp ? pop.tp.nr + "." : ""
        color: activPal.text; font.bold: true
      }

      Grid {
        columns: tempoPage.width < initRow.width + targetRow.width ? 1 : 2
        spacing: GLOB.fontSize() / 2
        Row {
          id: initRow
          spacing: GLOB.fontSize()
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("initial tempo").replace(" ", "<br>")
            color: activPal.text
          }
          SpinBox {
            editable: true
            anchors.verticalCenter: parent.verticalCenter
            from: 40; to: 240
            value: pop.tp ? pop.tp.initTempo : 40
            onValueModified: pop.tp.initTempo = value
          }
        }

        Row {
          id: targetRow
          spacing: GLOB.fontSize()
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("target tempo").replace(" ", "<br>")
            color: activPal.text
          }
          SpinBox {
            editable: true
            anchors.verticalCenter: parent.verticalCenter
            from: 40; to: 240
            value: pop.tp ? pop.tp.targetTempo : 40
            onValueModified: pop.tp.targetTempo = value
          }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "<u>" + qsTr("duration") + "</u>"
        color: activPal.text; font.bold: true
      }

      Grid {
        spacing: GLOB.fontSize()
        columns: tempoPage.width < barCol.width + beatCol.width + secCol.width ? 1 : 3
        Column {
          id: barCol
          SpinBox {
            id: barsSpin
            editable: true
            anchors.horizontalCenter: parent.horizontalCenter
            from: 1; to: 1000
            value: pop.tp ? pop.tp.bars : 1
            onValueModified: pop.tp.bars = value
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("bars", "", barsSpin.value)
            color: activPal.text
          }
        }
        Column {
          id: beatCol
          SpinBox {
            id: beatsSpin
            editable: true
            anchors.horizontalCenter: parent.horizontalCenter
            from: 1; to: 12000
            value: pop.tp ? pop.tp.beats : 1
            onValueModified: pop.tp.beats = value
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("beats", "", beatsSpin.value)
            color: activPal.text
          }
        }
        Column {
          id: secCol
          SpinBox {
            id: secSpin
            editable: true
            anchors.horizontalCenter: parent.horizontalCenter
            from: 1; to: 3600
            value: pop.tp ? pop.tp.seconds : 1
            onValueModified: pop.tp.seconds = value
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("seconds", "", secSpin.value)
            color: activPal.text
          }
        }
      }
    }
  }
}
