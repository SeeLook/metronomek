/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


AbstractButton {
  id: menuButt

  height: parent.height / 12; width: height / 3

  property var drawer: null

  background: Rectangle {
    color: GLOB.alpha(activPal.text, 20)
    radius: width / 4
  }
  contentItem: Column {
    width: parent.width
    spacing: height / 6
    topPadding: spacing
    Repeater {
      model: 3
      Rectangle {
        width: menuButt.width / 3; height: width; radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: activPal.text
      }
    }
  }

  onClicked: {
    if (!drawer) {
      var c = Qt.createComponent("qrc:/MainDrawer.qml")
      drawer = c.createObject(mainWindow)
    }
    drawer.open()
  }
}
