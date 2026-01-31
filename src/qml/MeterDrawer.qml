// SPDX-FileCopyrightText: 2019-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Drawer {
    id: mDrawer

    readonly property bool isMaterial: GLOB.isAndroid() || GLOB.isWindows()

    edge: Qt.RightEdge
    width: Math.max(FM.height * 4, countText.width + GLOB.fontSize())
    height: parent.Window.height
    padding: 0

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
                height: (mDrawer.height - countText.height - GLOB.fontSize() * (mDrawer.isMaterial ? 3 : 1)) / 12
                background: Rectangle {
                    color: cntButt.checked ? ActivPalette.highlight : (cntButt.index % 2 ? ActivPalette.base : ActivPalette.alternateBase)
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
                    text: cntButt.index > 0 ? cntButt.index + 1 : qsTr("none")
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
