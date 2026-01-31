// SPDX-FileCopyrightText: 2020-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Effects

Item {
    id: tip

    property alias color: bg.color
    property alias radius: bg.radius
    property bool raised: true
    property real shadowRadius: 8 // dummy
    property alias shadowColor: shd.shadowColor
    property alias border: bg.border
    property alias horizontalOffset: shd.shadowHorizontalOffset
    property alias verticalOffset: shd.shadowVerticalOffset

    Rectangle {
        id: bg

        anchors.fill: parent
        color: ActivPalette.base
        radius: GLOB.fontSize() / 2
        visible: false
        clip: true
    }

    MultiEffect {
        id: shd

        source: bg
        anchors.fill: bg
        shadowEnabled: true
        shadowColor: ActivPalette.shadow
        // blur: tip.shadowRadius / 64.0
        shadowHorizontalOffset: tip.raised ? GLOB.fontSize() / 2 : 0
        shadowVerticalOffset: tip.raised ? GLOB.fontSize() / 2 : 0
    }

}
