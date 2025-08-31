/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick

Text {
    id: txt

    onLinkActivated: (link) => {
        Qt.openUrlExternally(link);
    }
    color: ActivPalette.text

    // make hand cursor over link text
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: txt.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

}
