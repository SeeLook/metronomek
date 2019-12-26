/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12


Rectangle {
  width: parent.width; height: GLOB.fontSize() * 6
  color: activPal.window
  Text {
    anchors.centerIn: parent
    color: activPal.text
    text: "MetronomeK"
    font { pixelSize: GLOB.fontSize() * 2; bold: true }
  }
  
}
