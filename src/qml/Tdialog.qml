/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


Dialog {

  width: mainWindow.width; height: mainWindow.height

  scale: 0
  enter: Transition { NumberAnimation { property: "scale"; to: 1.0 }}
  exit: Transition { NumberAnimation { property: "scale"; to: 0 }}

  onVisibleChanged: {
    if (!visible)
      destroy()
  }

}
