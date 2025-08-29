/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek 1.0
import QtQuick 2.12

Item {
    property real imgFactor: 0.650926
    property alias innerColor: innerFill.color
    property alias outerColor: outerFill.color

    Text {
        id: innerFill

        color: GLOB.valueColor(activPal.window, 70)
        text: "\u00A1"

        font {
            family: "metronomek"
            pixelSize: parent.height
        }

    }

    Text {
        id: outerFill

        color: Qt.tint(GLOB.valueColor(activPal.window, 10), GLOB.alpha(activPal.highlight, 25))
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
