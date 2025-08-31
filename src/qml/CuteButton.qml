/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

AbstractButton {
    id: butt

    property alias border: bgRect.border
    property alias bgColor: bgRect.color
    property bool innerPress: pressAnim.running || pressed

    scale: innerPress ? 0.9 : 1
    onPressed: pressAnim.start()
    focusPolicy: Qt.NoFocus

    PauseAnimation {
        id: pressAnim

        duration: 100
    }

    Behavior on scale {
        NumberAnimation {
        }

    }

    background: TipRect {
        id: bgRect

        radius: height / 2
        raised: !innerPress

        Text {
            font.pixelSize: butt.height / 3
            text: butt.text
            color: ActivPalette.text
            anchors.centerIn: parent
            width: butt.width - GLOB.fontSize() * 2
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

    }

}
