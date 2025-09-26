/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick

SidePop {
    id: nextPop

    bgColor: ActivPalette.varTempo
    focus: true

    Text {
        id: nextText

        x: (parent.width - width) / 2
        scale: (nextPop.width - FM.height * 4) / width
        transformOrigin: Item.Top
        color: ActivPalette.tempoText
        style: Text.Outline
        styleColor: ActivPalette.base
        text: qsTr("Next tempo")
    }

    Text {
        x: (parent.width - width) / 2
        y: nextText.height * nextText.scale
        width: nextText.width * nextText.scale
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: ActivPalette.tempoText
        style: Text.Outline
        styleColor: ActivPalette.base
        text: qsTr("Tap, click or press any key.")
    }

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: nextPop.close()
        focus: true
        Keys.onPressed: nextPop.close()
    }

}
