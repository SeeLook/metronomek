/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick
import QtQuick.Effects

Item {
    id: tip

    property alias color: bg.color
    property alias radius: bg.radius
    property bool raised: true
    property real shadowRadius: 8.0 // dummy
    property alias shadowColor: shd.shadowColor
    property alias border: bg.border
    property alias horizontalOffset: shd.shadowHorizontalOffset
    property alias verticalOffset: shd.shadowVerticalOffset

    Rectangle {
        id: bg

        anchors.fill: parent
        color: activPal.base
        radius: GLOB.fontSize() / 2
        visible: false
        clip: true
    }

    MultiEffect {
        id: shd
        source: bg
        anchors.fill: bg
        shadowEnabled: true
        shadowColor: activPal.shadow
        // blur: tip.shadowRadius / 64.0
        shadowHorizontalOffset: raised ? GLOB.fontSize() / 2 : 0
        shadowVerticalOffset: raised ? GLOB.fontSize() / 2 : 0
    }
}


// Item {
//   property alias color: bg.color
//   property alias radius: bg.radius
//   property bool raised: true
//   property alias shadowRadius: shadow.radius
//   property alias shadowColor: shadow.color
//   property alias border: bg.border
//   property alias horizontalOffset: shadow.horizontalOffset
//   property alias verticalOffset: shadow.verticalOffset
// 
//   Rectangle {
//     id: bg
//     anchors.fill: parent
//     color: activPal.base
//     radius: parent.height / 10
//     visible: false
//     clip: true
//   }
// 
//   DropShadow {
//     id: shadow
//     width: bg.width + 2 * shadowRadius; height: bg.height + 2 * shadowRadius
//     x: -shadowRadius; y: -shadowRadius
//     layer.enabled: true // HACK: cache it to avoid sluggish animations on mobile
//     layer.sourceRect: Qt.rect(-shadowRadius, -shadowRadius, width, height)
//     horizontalOffset: bg.height / 50
//     verticalOffset: horizontalOffset
//     radius: bg.height / 10
//     samples: 1 + radius * 2
//     color: activPal.shadow
//     source: bg
//   }
// }
