/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick


Rectangle {
  anchors.fill: parent
  color: GLOB.valueColor(activPal.window, 30)
  radius: GLOB.fontSize() / 3
  clip: true
}
