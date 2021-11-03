/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12

import Metronomek 1.0

Item {
  property real imgFactor: 0.6509259259259259
  property alias innerColor: innerFill.color
  property alias outerColor: outerFill.color

  Text {
    id: innerFill
    font { family: "metronomek"; pixelSize: parent.height }
    color: GLOB.valueColor(activPal.window, 70)
    text: "\u00A1"
  }

  Text {
    id: outerFill
    font { family: "metronomek"; pixelSize: parent.height }
    color: GLOB.valueColor(activPal.window, 10)
    text: "\u00A2"
  }

  TmetroShape {
    width: parent.width; height: parent.height
  }
}
