// SPDX-FileCopyrightText: 2019-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

Text {
    id: txt

    onLinkActivated: link => {
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
