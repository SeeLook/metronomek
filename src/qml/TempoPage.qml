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
  topPadding: GLOB.fontSize() / 2; bottomPadding: GLOB.fontSize() / 2

  ListModel { id: tempoModel }

  ListView {
    id: chengesList
    width: parent.width; height: parent.height
    spacing: 1

    header: ComboBox {
      id: comboEdit
      width: parent.width
      editable: true
      model: speedHandler ? speedHandler.titleModel : null

      contentItem: TextField {
        width: parent.width
        placeholderText: qsTr("Rhythmic Composition")
        text: comboEdit.displayText
        selectedTextColor: activPal.highlightedText
        selectionColor: activPal.highlight
        selectByMouse: true
        onTextEdited: speedHandler.title = text
      }

      onActivated: speedHandler.setComposition(index)
    }

    model: tempoModel

    delegate: TempoPartDelegate {
      tp: modelData
      onClicked: {
        pop.tp = tp
        if (pop.height < tempoPage.height / 2) {
          var p = parent.mapToItem(tempoPage.contentItem, 0, y + height + fm.height / 2)
          if (p.y > tempoPage.height - pop.height - fm.height / 2)
            pop.y = p.y - pop.height - height - fm.height
          else
            pop.y = p.y
          pop.x = (tempoPage.contentItem.width - pop.width) / 2
        }
        pop.open()
      }
    }

    footer: Column {
      width: parent.width
      spacing: fm.height / 2
      Button {
        width: parent.width
        text: qsTr("Add tempo change")
        onClicked: speedHandler.addTempo()
      }
      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: activPal.text
        text: qsTr("Tap or click to edit tempo change.") + "<br><font color=\"red\">"
            + qsTr("Drag the item left or right to remove it.")
      }
    }
  }

  standardButtons: Dialog.Ok | Dialog.Help

  Component.onCompleted: {
    mainWindow.dialogItem = tempoPage
    footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK")
    footer.standardButton(Dialog.Help).text = qsTr("More") + " ..."
    speedHandler = SOUND.speedHandler()
    speedHandler.emitAllTempos()
  }

  Connections {
    target: speedHandler
    onAppendTempoChange: tempoModel.append( {"tempoPart": tp} )
    onRemoveTempoChange: tempoModel.remove(tpId)
    onClearAllChanges: tempoModel.clear()
  }

  Menu {
    y: tempoPage.height - height - tempoPage.implicitFooterHeight
    id: moreMenu
    MenuItem {
      text: qsTr("New composition")
      onClicked: speedHandler.newComposition()
    }
    MenuItem {
      text: qsTr("Duplicate")
    }
    MenuItem {
      text: qsTranslate("QFileDialog", "Open")
    }
    MenuItem {
      text: qsTranslate("QFileDialog", "Save As")
    }
    MenuItem {
      text: qsTranslate("QPlatformTheme", "Reset")
    }
    MenuItem {
      text: qsTranslate("QFileDialog", "Remove")
    }
  }

  onHelpRequested: moreMenu.open()

  Dialog {
    id: pop

    scale: 0
    enter: Transition { NumberAnimation { property: "scale"; to: 1.0 }}
    exit: Transition { NumberAnimation { property: "scale"; to: 0 }}

    property TempoPart tp: null
    property real extraH: topPadding + bottomPadding + implicitFooterHeight + implicitHeaderHeight

    height: Math.min(extraH + tCol.height, tempoPage.height)
    width: tCol.width + leftPadding + rightPadding
    title: pop.tp ? pop.tp.nr + "." : ""

    Flickable {
      height: Math.min(tCol.height + fm.height, tempoPage.height - pop.extraH)
      width: tCol.width
      contentHeight: tCol.height; contentWidth: tCol.width
      clip: true
      Column {
        id: tCol
        spacing: GLOB.fontSize() / (GLOB.isAndroid() ? 6 : 2)
        padding: GLOB.fontSize() / 4

        Grid {
          columns: tempoPage.width < initCtrl.width + targetCtrl.width ? 1 : 2
          spacing: GLOB.fontSize() / 2

          TempoEdit {
            id: initCtrl
            text: qsTr("initial tempo").replace(" ", "<br>")
            tempo: pop.tp ? pop.tp.initTempo : 40
            onTempoModified: pop.tp.initTempo = tempo
          }

          TempoEdit {
            id: targetCtrl
            text: qsTr("target tempo").replace(" ", "<br>")
            tempo: pop.tp ? pop.tp.targetTempo : 40
            onTempoModified: pop.tp.targetTempo = tempo
          }
        }

        Row {
          spacing: GLOB.fontSize()
          anchors.horizontalCenter: parent.horizontalCenter
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Meter")
            color: activPal.text
          }
          SpinBox {
            editable: true
            anchors.verticalCenter: parent.verticalCenter
            from: 1; to: 12
            value: pop.tp ? pop.tp.meter : 4
            onValueModified: pop.tp.meter = value
          }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: GLOB.fontSize() * 2
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Duration")
            color: activPal.text; font.bold: true
          }
          CheckBox {
            id: infiChB
            enabled: pop.tp && pop.tp.initTempo === pop.tp.targetTempo
            anchors.verticalCenter: parent.verticalCenter
            checked: pop.tp && pop.tp.infinite
            onToggled: pop.tp.infinite = checked
            text: qsTr("infinite")
          }
        }

        Grid {
          enabled: !infiChB.checked
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
              color: enabled ? activPal.text : disblPal.text
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
              color: enabled ? activPal.text : disblPal.text
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
              color: enabled ? activPal.text : disblPal.text
            }
          }
        }
      }
    } // Flickable

    standardButtons: Dialog.Ok
    Component.onCompleted: footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK")
  } // Dialog

}
