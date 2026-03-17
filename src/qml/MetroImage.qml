// SPDX-FileCopyrightText: 2019-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

Item {
    property real imgFactor: 0.650926
    property alias innerColor: innerFill.color
    property alias outerColor: outerFill.color

    Text {
        id: innerFill

        color: GLOB.valueColor(ActivPalette.window, 70)
        text: "\u00A1"

        font {
            family: "metronomek"
            pixelSize: parent.height
        }
    }

    Text {
        id: outerFill

        color: Qt.tint(GLOB.valueColor(ActivPalette.window, 10), GLOB.alpha(ActivPalette.highlight, 25))
        text: "\u00A2"

        font {
            family: "metronomek"
            pixelSize: parent.height
        }
    }

    TmetroShape {
        width: parent.width
        height: parent.height
    }
}
