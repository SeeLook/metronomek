/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


Dialog {

  width: Math.min(mainWindow.width, fm.height * 40)
  height: mainWindow.height
  x: (parent.width - width) / 2; y: (parent.height - height) / 2

  enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1 }}
  exit: Transition { NumberAnimation { property: "opacity"; to: 0 }}

  onVisibleChanged: {
    if (!visible)
      destroy()
  }

}
