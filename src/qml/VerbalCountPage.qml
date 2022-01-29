/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

import Metronomek 1.0


Tdialog {
  id: vCntPage

  visible: true
  padding: GLOB.fontSize() / 2

  ButtonGroup { id: soundsGr }

  // private
  property CountManager cntMan: SOUND.countManager()

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
      currentIndex: -1
      model: 12

      width: parent ? parent.width : 0; height: parent ? parent.height : 0
      spacing: 1
      delegate: Rectangle {
        id: bgRect
        property alias spectrum: numSpec
        width: parent ? parent.width : 0
        height: fm.height * 5 + (numList.currentIndex === index ? buttonsRect.height + fm.height / 3 : 0)
        Behavior on height { NumberAnimation {} }
        color: Qt.tint(index % 2 ? activPal.base : activPal.alternateBase, GLOB.alpha(activPal.highlight, numList.currentIndex === index ? 20 : 0))
        NumeralSpectrum {
          id: numSpec
          nr: index
          clip: true
          width: parent.width; height: fm.height * 5
          Text {
            x: fm.height / 4; y: fm.height / 4
            color: numList.currentIndex === index ? activPal.highlight : activPal.text
            text: index + 1
            style: Text.Outline; styleColor: numList.currentIndex === index ? activPal.text : bgRect.color
            font { pixelSize: parent.height * 0.25; bold: true }
          }
          Rectangle {
            id: playTick
            width: fm.height / 4; height: parent.height
            color: activPal.highlight
            visible: playAnim.running
          }
          Text {
            text: numSpec.recMessage
            anchors.centerIn: parent
            color: "red"; style: Text.Outline; styleColor: bgRect.color
            font { pixelSize: parent.height / 3; bold: true }
          }
          NumberAnimation {
            id: playAnim
            target: playTick; property: "x"
            duration: 750
            from: 0; to: numSpec.width
          }
          MouseArea {
            anchors.fill: parent
            onClicked: numList.currentIndex = index
          }
          Component.onCompleted: cntMan.addSpectrum(numSpec)
        }
        Flow {
          id: buttonsRect
          scale: numList.currentIndex === index ? 1 : 0
          transformOrigin: Item.Top
          Behavior on scale { NumberAnimation {} }
          anchors { top: spectrum.bottom }
          spacing: bgRect.width * 0.01
          CuteButton {
            width: bgRect.width * 0.24; height: fm.height * 2
            text: qsTranslate("QShortcut", "Play")
            bgColor: Qt.tint(activPal.button, GLOB.alpha("green", 40))
            onClicked: {
              playAnim.start()
              cntMan.play(index)
            }
          }
          //CuteButton {
            //width: bgRect.width * 0.24; height: fm.height * 2
            //text: qsTr("Amplify")
            //bgColor: Qt.tint(activPal.button, GLOB.alpha("blue", 40))
          //}
          Item {
            width: bgRect.width * 0.49 /*0.24*/; height: fm.height * 2
          }
          CuteButton {
            width: bgRect.width * 0.24; height: fm.height * 2
            text: qsTr("Record")
            bgColor: Qt.tint(activPal.button, GLOB.alpha("red", 40))
            onClicked: cntMan.rec(index)
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

  standardButtons: Dialog.Ok | Dialog.Cancel | Dialog.Help
  Component.onCompleted: {
    //footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "Save")
    SOUND.initCountingSettings()
    footer.standardButton(Dialog.Help).text = qsTranslate("TempoPage", "Actions")
  }
  Component.onDestruction: {
    SOUND.restoreAfterCountSettings()
  }

  onHelpRequested: moreMenu.open()

  Menu {
    id: moreMenu
    y: vCntPage.height - height - vCntPage.implicitFooterHeight - vCntPage.implicitHeaderHeight
    MenuItem {
      text: qsTr("Load from file")
      onTriggered: {
        var fd = Qt.createComponent("qrc:/BeatFileDialog.qml").createObject(mainWindow)
        fd.beatFile.connect(function(beatFile) { cntMan.importFormFile(beatFile) } )
      }
    }
    MenuItem {
      text: qsTr("Align")
    }
  }

}
