/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


AbstractButton {
  id: butt
  property alias border: bgRect.border
  property alias bgColor: bgRect.color

  scale: innerPress ? 0.9 : 1
  Behavior on scale { NumberAnimation {} }

  onPressed: pressAnim.start()
  property bool innerPress: pressAnim.running || pressed
  PauseAnimation { id: pressAnim; duration: 100 }

  focusPolicy: Qt.NoFocus

  background: TipRect {
    id: bgRect
    radius: height / 2; raised: !innerPress
    Text {
      font.pixelSize: butt.height / 3
      text: butt.text
      color: activPal.text
      anchors.centerIn: parent
      width: butt.width - GLOB.fontSize() * 2
      wrapMode: Text.WordWrap
      horizontalAlignment: Text.AlignHCenter
    }
  }

}
