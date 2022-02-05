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

  // private
  property CountManager cntMan: SOUND.countManager()

  Connections {
    target: cntMan
    onAppendToLocalModel: {
      appendToLocalModel(modelEntry)
      localList.positionViewAtEnd()
    }
  }

  ListModel { id: localCntsMod }

  Column {
    spacing: GLOB.fontSize()
    ListView {
      id: localList
      width: vCntPage.width - GLOB.fontSize()
      height: (vCntPage.height - vCntPage.implicitFooterHeight) / 2 - GLOB.fontSize() * 2
      spacing: 1
      currentIndex: -1
      model: localCntsMod
      clip: true

      header: Rectangle {
        width: parent.width; height: fm.height * 1.5; color: activPal.text
        Text {
          anchors.centerIn: parent
          color: activPal.base
          text: qsTr("available sounds of counting")
        }
      }

      ScrollBar.vertical: ScrollBar {}

      delegate: Rectangle {
        id: bgRect
        width: parent ? parent.width : 0
        height: fm.height * 5
        color: Qt.tint(index % 2 ? activPal.base : activPal.alternateBase, GLOB.alpha(activPal.highlight, localList.currentIndex === index ? 20 : 0))
        Row {
          //anchors.centerIn: parent
          anchors.verticalCenter: parent.verticalCenter
          spacing: fm.height
          Text {
            anchors.verticalCenter: parent.verticalCenter
            color: activPal.text
            text: localCntsMod.get(index).langID
            font { bold: true }
          }
          Column {
            spacing: fm.height / 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              color: activPal.text
              text: localCntsMod.get(index).langName
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              color: activPal.text
              text: localCntsMod.get(index).cntName
              font.pixelSize: fm.height * 1.2
            }
          }
        }
      }

      Component.onCompleted: {
        if (localCntsMod.count == 0) {
          var wavMod = cntMan.countingModelLocal()
          for (var w = 0; w < wavMod.length; ++w)
            appendToLocalModel(wavMod[w])
        }
      }
    }

    CuteButton {
      anchors.horizontalCenter: parent.horizontalCenter
      width: vCntPage.width - GLOB.fontSize() * 4; height: fm.height * 2.5
      bgColor: Qt.tint(activPal.window, GLOB.alpha(activPal.highlight, 20))
      text: qsTr("Prepare own verbal counting")
      onClicked: Qt.createComponent("qrc:/VerbalCountEdit.qml").createObject(mainWindow)
    }

    ListModel { id: onlineMod }

    ListView {
      id: onlineList
      width: vCntPage.width - GLOB.fontSize()
      height: (vCntPage.height - vCntPage.implicitFooterHeight) / 2 - GLOB.fontSize() * 2
      spacing: 1
      clip: true

      currentIndex: -1
      model: onlineMod

      header: Rectangle {
        width: parent.width; height: fm.height * 1.5; color: activPal.text
        Row {
          anchors.centerIn: parent
          Text {
            color: activPal.base
            text: qsTr("sounds of counting to download")
          }
        }
      }

      delegate: Rectangle {
        id: bgRect
        width: parent ? parent.width : 0
        height: fm.height * 5
        color: Qt.tint(index % 2 ? activPal.base : activPal.alternateBase, GLOB.alpha(activPal.highlight, localList.currentIndex === index ? 20 : 0))
        Text {
          anchors.verticalCenter: parent.verticalCenter
          color: activPal.text
          text: onlineMod.get(index).langID
          font { bold: true }
        }
        Column {
          spacing: fm.height / 4
          anchors.centerIn: parent
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: activPal.text
            text: onlineMod.get(index).langName
          }
        }
        Button {
          anchors { right: parent.right; verticalCenter: parent.verticalCenter }
          enabled: !cntMan.downloading
          text: qsTr("Download") +"\n" + onlineMod.get(index).size + " kB"
          onClicked: cntMan.downloadCounting(index)
        }
      }

      Component.onCompleted: {
        if (localCntsMod.count == 0) {
          var oMod = cntMan.onlineModel()
          for (var w = 0; w < oMod.length; ++w) {
            var wav = oMod[w].split(";")
            onlineMod.append({ "langID": wav[0], "langName": wav[1] + " / " + wav[2], "size": wav[3] })
          }
        }
      }

      ScrollBar.vertical: ScrollBar {}
    }
  }

  standardButtons: Dialog.Ok
  Component.onCompleted: {
    SOUND.initCountingSettings()
  }
  Component.onDestruction: {
    SOUND.restoreAfterCountSettings()
  }

  function appendToLocalModel(modelEntry) {
    var wav = modelEntry.split(";")
    localCntsMod.append({"langID": wav[0], "langName": wav[1], "cntName": wav[2]})
  }

}
