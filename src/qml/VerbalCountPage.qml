/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

import Metronomek 1.0


Tdialog {
  id: vCntPage

  visible: true
  padding: GLOB.fontSize() / 4

  // private
  property CountManager cntMan: SOUND.countManager()

  Connections {
    target: cntMan
     function onAppendToLocalModel(modelEntry) {
      appendToLocalModel(modelEntry)
      localList.positionViewAtEnd()
    }
    function onDownProgress(prog) {
      progBar.indeterminate = false
      progBar.value = prog
      if (prog >= 1)
        progBar.destroy(1000)
      else if (prog < 0)
        progBar.destroy()
    }
  }

  ListModel { id: localCntsMod }

  Column {
    ListView {
      id: localList
      width: vCntPage.width - GLOB.fontSize()
      height: Math.min(contentHeight, (vCntPage.height - vCntPage.implicitFooterHeight) / 2 - GLOB.fontSize() * 2)
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

      delegate: DragDelegate {
        id: bgRect
        dragEnabled: index > 0
        width: parent ? parent.width : 0; height: fm.height * 3
        color: Qt.tint(index % 2 ? activPal.base : activPal.alternateBase,
                       GLOB.alpha(toDel ? "red" : activPal.highlight,
                                  pressed || containsMouse ? 50 : (cntMan.localModelId === index ? 20 : 0)))
        property var modelData: localCntsMod.get(index)
        Row {
          anchors.verticalCenter: parent.verticalCenter
          spacing: fm.height / 2
          Rectangle {
            width: fm.height * 4.5; height: bgRect.height
            color: cntMan.localModelId == index ? activPal.highlight : "transparent"
            Text {
              anchors.centerIn: parent
              color: cntMan.localModelId == index ? activPal.highlightedText : activPal.text
              text: modelData ? modelData.langID : ""
              font { bold: true }
            }
          }
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: bgRect.width - fm.height * 5
            Text {
              width: parent.width; horizontalAlignment: Text.AlignHCenter
              color: activPal.text
              text: modelData ? modelData.langName : ""
              font.pixelSize: fm.height; minimumPixelSize: fm.height / 2
              fontSizeMode: Text.HorizontalFit; elide: Text.ElideRight
            }
            Text {
              width: parent.width; horizontalAlignment: Text.AlignHCenter
              color: activPal.text
              text: modelData ? modelData.cntName : ""
              font.pixelSize: fm.height * 1.1; minimumPixelSize: fm.height * 0.7
              fontSizeMode: Text.HorizontalFit; elide: Text.ElideRight
            }
          }
        }
        onClicked: cntMan.localModelId = index
        onRemoved: {
          cntMan.removeLocalWav(index)
          localCntsMod.remove(index)
        }
      }

      Component.onCompleted: {
        if (localCntsMod.count == 0) {
          var wavMod = cntMan.countingModelLocal()
          for (var w = 0; w < wavMod.length; ++w)
            appendToLocalModel(wavMod[w])
          localList.positionViewAtIndex(cntMan.localModelId, ListView.Contain)
        }
      }
    }

    Rectangle { width: vCntPage.width - GLOB.fontSize(); height: fm.height / 2; color: activPal.text }

    ListModel { id: onlineMod }

    ListView {
      id: onlineList
      width: vCntPage.width - GLOB.fontSize()
      height: vCntPage.height - vCntPage.implicitFooterHeight - localList.height - fm.height
      spacing: 1
      clip: true

      currentIndex: -1
      model: onlineMod

      header: Rectangle {
        width: parent.width; height: fm.height * 1.5; color: activPal.highlight
        Row {
          anchors.centerIn: parent
          Text {
            color: activPal.highlightedText
            text: qsTr("sounds of counting to download")
          }
        }
      }

      delegate: Rectangle {
        id: bgRect
        width: parent.width; height: fm.height * 2.5
        color: ma.pressed || ma.containsMouse ? Qt.tint(activPal.base, GLOB.alpha(activPal.highlight, 50))
                                              : (index % 2 ? activPal.base : activPal.alternateBase)
        property var modelEntry: onlineMod.get(index)
        Text {
          x: fm.height / 2
          anchors.verticalCenter: parent.verticalCenter
          color: activPal.text
          text: modelEntry.langID
          font { bold: true }
        }
        Text {
          x: fm.height * 3.5
          width: bgRect.width - fm.height * 9
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          anchors.verticalCenter: parent.verticalCenter
          color: activPal.text
          text: modelEntry.langName
        }
        Row {
          anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: fm.height / 4 }
          Text {
            anchors.bottom: parent.bottom
            color: activPal.text
            text: qsTranslate("QFileSystemModel", "%1 KB").arg(modelEntry.size) + " "
          }
          Text {
            color: activPal.highlight
            text: "\u00c1"; font { family: "Metronomek"; pixelSize: fm.height * 1.7 }
          }
        }
        MouseArea {
          id: ma
          enabled: !cntMan.downloading
          anchors.fill: parent
          hoverEnabled: !GLOB.isAndroid()
          onClicked: {
            cntMan.downloadCounting(index)
            progBar = progBarComp.createObject(bgRect)
          }
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

  property var progBar: null
  Component {
    id: progBarComp
    ProgressBar {
      width: parent.width - fm.height; height: fm.height / 3
      anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
      indeterminate: true
      CuteButton {
        visible: cntMan.downloading
        width: fm.height * 5; height: fm.height * 2
        x: parent.width - fm.height * 5; y: -fm.height * 2
        text: qsTranslate("QPlatformTheme", "Abort")
        bgColor: Qt.tint(activPal.button, GLOB.alpha("red", 40))
        onClicked: cntMan.abortDownload()
      }
    }
  }

  standardButtons: Dialog.Ok | Dialog.Help
  Component.onCompleted: {
    footer.standardButton(Dialog.Help).text = GLOB.TR("TempoPage", "Actions")
  }

  onHelpRequested: actMenuComp.createObject(mainWindow)

  Component {
    id: actMenuComp
    Menu {
      id: actionsMenu
      visible: true
      y: vCntPage.height - height - vCntPage.implicitFooterHeight
      x: (vCntPage.width - width) / 2

      MenuItem {
        text: qsTr("Prepare own verbal counting")
        onTriggered: Qt.createComponent("qrc:/VerbalCountEdit.qml").createObject(mainWindow)
      }
      MenuItem {
        text: qsTr("Update online counting list")
      }
      MenuItem {
        text: qsTranslate("QShortcut", "Help")
        onTriggered: {
          Qt.createComponent("qrc:/HelpPop.qml").createObject(mainWindow, {
            visible: true,
            helpText: qsTr("Matronomek is installed with verbal counting only in English language.")
                    + "<br>" + qsTr("But counting for other languages can be easy obtained:")
                    + "<ul><li>" + qsTr("by downloading files available online (for free)")
                    + "</li><li>" + qsTr("or by recording own counting.")
                    + "</li></ul><br><a href=\"https://metronomek.sourceforge.io\">"
                    + qsTr("Read more online.") + "</a>"
          })
        }
      }
      Component.onCompleted: {
        var maxW = 0
        for (var m = 0; m < actionsMenu.count; ++m)
          maxW = Math.max(maxW, itemAt(m).width)
        width = Math.min(vCntPage.width - fm.height * 3, maxW + 2 * fm.height)
      }
    }
  }

  function appendToLocalModel(modelEntry) {
    var wav = modelEntry.split(";")
    localCntsMod.append({"langID": wav[0], "langName": wav[1], "cntName": wav[2]})
  }

}
