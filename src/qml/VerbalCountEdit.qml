/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Tdialog {
  id: vCntEdit

  visible: true
  padding: GLOB.fontSize() / 2

  // private
  property CountManager cntMan: SOUND.countManager()


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

  standardButtons: Dialog.RestoreDefaults | Dialog.Cancel | Dialog.Help
  Component.onCompleted: {
    footer.standardButton(Dialog.RestoreDefaults).text = qsTranslate("QPlatformTheme", "Save")
    footer.standardButton(Dialog.Help).text = qsTranslate("TempoPage", "Actions")
//     SOUND.initCountingSettings()
  }
  //Component.onDestruction: {
    //SOUND.restoreAfterCountSettings()
  //}

  onHelpRequested: moreMenu.open()

  onReset: {
    Qt.createComponent("qrc:/CountingLangPop.qml").createObject(mainWindow)
  }

  Menu {
    id: moreMenu
    y: vCntEdit.height - height - vCntEdit.implicitFooterHeight - vCntEdit.implicitHeaderHeight

    MenuItem {
      text: qsTr("Align")
    }
    Component.onCompleted: {
      if (!GLOB.isAndroid())
        moreMenu.insertItem(0, fromFileComp.createObject())
    }
  }

  Component {
    id: fromFileComp
    MenuItem {
      text: qsTr("Load from file")
      onTriggered: {
        cntMan.getSoundFile()
      }
    }
  }

}
