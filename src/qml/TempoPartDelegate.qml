/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick

pragma ComponentBehavior: Bound

DragDelegate {
    id: tpDelegate

    property TempoPart tp: null
    property int nr: tp ? tp.nr + 1 : -1

    dragEnabled: ListView.view.model.count > 1
    width: parent ? parent.width : 0
    height: tCol ? tCol.height : 0
    color: pressed || containsMouse ? Qt.tint(ActivPalette.base, GLOB.alpha(toDel ? "red" : ActivPalette.highlight, 50)) : (nr % 2 ? ActivPalette.base : ActivPalette.alternateBase)
    onRemoved: (tpDelegate.parent as TempoPage).speedHandler.removeTempo(tp.nr - 1)

    Column {
        id: tCol

        spacing: GLOB.fontSize() / 2
        padding: GLOB.fontSize() / 4
        width: parent.width - GLOB.fontSize()

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tpDelegate.tp ? tpDelegate.tp.tempoText : ""
            color: ActivPalette.text
        }

        Text {
            text: GLOB.TR("TempoPage", "Meter") + " (" + GLOB.TR("MainWindow", "count to") + "): " + "<b>" + (tpDelegate.tp ? tpDelegate.tp.meter : 4) + "</b>"
            color: ActivPalette.text
        }

        Text {
            text: GLOB.TR("TempoPage", "Duration") + ": "
                    + (tpDelegate.tp && tpDelegate.tp.infinite ? GLOB.TR("TempoPage", "infinite") : "<br>"
                    + GLOB.chopS(qsTr("<b>%n</b> bars", "", tpDelegate.tp ? tpDelegate.tp.bars : 0), tpDelegate.tp ? tpDelegate.tp.bars : 0)
                    + " = " + GLOB.chopS(qsTr("<b>%n</b> beats", "", tpDelegate.tp ? tpDelegate.tp.beats : 0), tpDelegate.tp ? tpDelegate.tp.beats : 0)
                    + " = " + GLOB.chopS(qsTr("<b>%n</b> seconds", "", tpDelegate.tp ? tpDelegate.tp.seconds : 0), tpDelegate.tp ? tpDelegate.tp.seconds : 0))
            color: ActivPalette.text
        }

    }

}
