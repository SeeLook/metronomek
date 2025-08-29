/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Controls 2.12

/**
 * Popup that jumps from bottom
 */
Popup {
    id: sidePop

    property alias bgColor: bg.color

    signal done()

    padding: fm.height / 2
    width: Math.min(mainWindow.width, fm.height * 60)
    height: mainWindow.height * 0.2
    x: (parent.width - width) / 2
    y: parent.height + height
    onClosed: {
        done();
        destroy();
    }

    enter: Transition {
        NumberAnimation {
            duration: 300
            property: "y"
            to: mainWindow.height - height + fm.height
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

        color: activPal.varTempo
        radius: fm.height
    }

}
