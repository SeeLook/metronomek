/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

/**
 * Popup that jumps from bottom
 */
Popup {
    id: sidePop

    property alias bgColor: bg.color

    signal done()

    padding: FM.height / 2
    width: Math.min(mainWindow.width, FM.height * 60)
    height: mainWindow.height * 0.2
    x: (parent.width - width) / 2
    y: parent.height + height
    z: 50000

    onClosed: {
        done();
        destroy();
    }

    enter: Transition {
        NumberAnimation {
            duration: 300
            property: "y"
            to: mainWindow.height - height + FM.height
        }

    }

    exit: Transition {
        NumberAnimation {
            duration: 300
            property: "y"
            to: mainWindow.height + height
        }

    }

    background: TipRect {
        id: bg

        color: ActivPalette.varTempo
        radius: FM.height
    }

}
