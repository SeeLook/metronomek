/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick


Text {
  onLinkActivated: Qt.openUrlExternally(link)
//   color: activPal.text
  MouseArea { // make hand cursor over link text
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
  }
}
