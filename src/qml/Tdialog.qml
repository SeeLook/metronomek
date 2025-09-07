/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Dialog {
    width: Math.min(Overlay.overlay.width, FM.height * 40)
    height: Overlay.overlay.height
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    padding: 0
    margins: 0

    background: Background {}

    onVisibleChanged: {
        if (!visible)
            destroy();
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
        }
    }

}
