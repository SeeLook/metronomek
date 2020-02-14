/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtGraphicalEffects 1.12


Item {
  property real imgFactor: 0.6509259259259259
  property alias innerColor: innerOver.color
  property alias outerColor: outerOver.color
  property alias shapeColor: shapeOver.color

  Image {
    id: bgInner
    anchors.fill: parent
    source: "qrc:/bg-inner.png"
  }
  ColorOverlay {
    id: innerOver
    anchors.fill: bgInner
    source: bgInner
    color: "#7c7c7c"
  }

  Image {
    id: bgOuter
    anchors.fill: parent
    source: "qrc:/bg-outer.png"
  }
  ColorOverlay {
    id: outerOver
    anchors.fill: bgOuter
    source: bgOuter
    color: "#bdbdbd"
  }

  Image {
    id: bgShape
    anchors.fill: parent
    source: "qrc:/bg-shape.png"
    visible: false
//     mipmap: true
    // TODO it increases launch time but reduces pixel artifacts. Doesn't work with emulator
  }
  ColorOverlay {
    id: shapeOver
    anchors.fill: bgShape
    source: bgShape
    color: "black"
  }
}
