/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtGraphicalEffects 1.0


Item {
  property alias color: bg.color
  property alias radius: bg.radius
  property bool raised: true
  property alias shadowRadius: shadow.radius
  property alias shadowColor: shadow.color
  property alias border: bg.border
  property alias horizontalOffset: shadow.horizontalOffset
  property alias verticalOffset: shadow.verticalOffset

  Rectangle {
    id: bg
    anchors.fill: parent
    color: activPal.base
    radius: parent.height / 10
    visible: false
    clip: true
  }

  DropShadow {
    id: shadow
    anchors.fill: bg
    horizontalOffset: raised ? height / 50 : 0
    verticalOffset: horizontalOffset
    radius: raised ? parent.height / 10 : 0
    samples: 1 + radius * 2
    color: activPal.shadow
    source: bg
  }
}
