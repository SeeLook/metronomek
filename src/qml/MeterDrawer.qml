/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Drawer {
    id: mDrawer

    edge: Qt.RightEdge
    width: FM.height * (GLOB.isAndroid() ? 4 : 5)
    height: mainWindow.height
    padding: 0
    topMargin: GLOB.fontSize()
    bottomMargin: GLOB.fontSize()

    Column {
        width: parent.width

        Label {
            id: countText

            text: qsTranslate("MainWindow", "count to") + ":"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            width: mDrawer.width
            height: GLOB.fontSize()
        }

        Repeater {
            model: 12

            AbstractButton {
                id: cntButt
                required property int index
                width: mDrawer.width
                height: (mDrawer.height - countText.height - GLOB.fontSize() * 3) / 12
                background: Rectangle {
                    color: cntButt.checked ? ActivPalette.highlight : (index % 2 ? ActivPalette.base : ActivPalette.alternateBase)
                }
                Text {
                    x: GLOB.fontSize() / 2
                    width: parent.width - GLOB.fontSize()
                    height: parent.height
                    anchors.centerIn: parent
                    font {
                        pixelSize: cntButt.height * 0.8
                        bold: cntButt.checked
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    minimumPixelSize: GLOB.fontSize()
                    fontSizeMode: Text.Fit
                    text: index > 0 ? index + 1 : qsTr("none")
                    color: cntButt.checked ? ActivPalette.highlightedText : ActivPalette.text
                    style: cntButt.checked ? Text.Outline : Text.Normal
                    styleColor: cntButt.checked ? ActivPalette.base : "transparent"
                }
                checked: SOUND.meter === index + 1
                onClicked: {
                    SOUND.meter = index + 1;
                    mDrawer.close();
                }
                checkable: true
            }

        }

    }

}
