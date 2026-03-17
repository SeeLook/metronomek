// SPDX-FileCopyrightText: 2021-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
