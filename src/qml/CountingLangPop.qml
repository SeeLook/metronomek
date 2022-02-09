/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


SidePop {
  id: countPop

  property var langModel: cntMan.languagesModel()

  visible: true
  modal: true

  bgColor: Qt.tint(activPal.window, GLOB.alpha(activPal.highlight, 30))

  height: col.height + fm.height * 2

  ListModel { id: langList }

  Column {
    id: col
    x: (parent.width - width) / 2
    spacing: fm.height / 2

    TextField {
      id: cntName
      anchors.horizontalCenter: parent.horizontalCenter
      width: countPop.width - fm.height * 4
      placeholderText: qsTranslate("QDirModel", "Name")
      horizontalAlignment: TextInput.AlignHCenter
    }
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: fm.height
      Text {
        id: lt
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("language") + ":"
        color: activPal.text
      }
      ComboBox {
        id: langCombo
        width: countPop.width - fm.height * 4 - lt.width
        model: langList
        textRole: "langName"
        valueRole: "langID"
        popup.width: GLOB.isAndroid() ? countPop.width - fm.height * 4 : langCombo.width
        popup.x: -fm.height * 4
      }
    }
    Text {
      width: countPop.width - 6 * fm.height
      color: activPal.text
      wrapMode: Text.WordWrap
      text: qsTr("Consider to share this counting audio data.")
    }
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: fm.height
      Button {
        text: GLOB.TR("QPlatformTheme", "Save")
        onClicked: {
          cntMan.storeCounting(langList.get(langCombo.currentIndex).langID, cntName.text)
          close()
        }
      }
      Button {
        text: GLOB.TR("QPlatformTheme", "Cancel")
        onClicked: countPop.close()
      }
    }
  }

  Component.onCompleted: {
    var currL = cntMan.currentLanguage()
    for (var l = 0; l < langModel.length; ++l) {
      var lang = langModel[l].split(";")
      langList.append({"langName": lang[0], "langID": lang[1]})
      if (currL == lang[1])
        langCombo.currentIndex = l
    }
  }
}
