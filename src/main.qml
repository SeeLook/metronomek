/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.14
import QtQuick.Window 2.14


Window {
  visible: true
  height: 480; width: height * 0.6537809426924381
  title: qsTr("Metronomek")

  Image {
    source: "qrc:/bg.png"
    height: parent.height; width: height * (sourceSize.width / sourceSize.height)
  }
}
