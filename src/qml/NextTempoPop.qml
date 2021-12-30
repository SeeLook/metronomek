/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


Popup {
  signal done()

  width: Math.min(mainWindow.width, fm.height * 60)
  height: mainWindow.height * 0.2
  x: (parent.width - width) / 2
  y: parent.height + height
  enter: Transition { NumberAnimation { duration: 300; property: "y"; to: mainWindow.height - height + fm.height }}
  exit: Transition { NumberAnimation { duration: 300; property: "y"; to: parent.height + height }}
  background: TipRect { color: "skyblue"; radius: fm.height }
  focus: true // HACK for onPressed

  Text {
    id: nextText
    x: (parent.width - width) / 2
    scale: (metro.width - fm.height * 4) / width
    transformOrigin: Item.Top
    color: activPal.text
    text: qsTr("Next tempo")
  }

  Text {
    x: (parent.width - width) / 2
    y: nextText.height * nextText.scale
    width: nextText.width * nextText.scale
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.WordWrap
    color: activPal.text
    text: qsTr("Tap, click or press any key.")
  }

  MouseArea {
    width: parent.width; height: parent.height
    onClicked: close()
    focus: true // HACK for onPressed
    Keys.onPressed: close()
  }

  onClosed: {
    done()
    destroy()
  }
}
