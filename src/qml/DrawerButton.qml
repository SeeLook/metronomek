/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

AbstractButton {
    id: dButt

    property color bgColor: ActivPalette.window
    property bool innerPress: pressAnim.running || pressed

    implicitWidth: parent.width
    implicitHeight: FM.height * 2.4
    focusPolicy: Qt.NoFocus

    onPressed: pressAnim.start()

    PauseAnimation {
        id: pressAnim
        duration: 100
    }

    background: Rectangle {
        color: dButt.innerPress ? ActivPalette.highlight : ActivPalette.window

        Text {
            width: parent.width - (dButt.checkable ? (chLoader.item ? (chLoader.item as AbstractButton).width : 0) : 0)
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: FM.height
            text: dButt.text
            font.pixelSize: FM.height * 0.9
            minimumPixelSize: FM.height / 2
            fontSizeMode: Text.Fit
            textFormat: Text.StyledText
            elide: Text.ElideRight
            color: dButt.innerPress ? ActivPalette.highlightedText : ActivPalette.text
        }

        Loader {
            id: chLoader

            active: dButt.checkable

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            sourceComponent: AbstractButton {
                id: chB

                checkable: true
                checked: dButt.checked
                scale: dButt.innerPress ? 0.8 : 1
                onToggled: {
                    dButt.toggle();
                    dButt.toggled();
                }

                Behavior on scale {
                    NumberAnimation {}

                }

                indicator: TipRect {
                    color: dButt.bgColor
                    x: -width - (GLOB.fontSize() / (GLOB.isAndroid() ? 2 : 1))
                    y: (parent.height - height) / 2
                    width: FM.height * 1.6
                    height: width

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: width
                        radius: width / 8
                        color: chB.checked ? dButt.bgColor : ActivPalette.base

                        border {
                            width: chB.checked ? 0 : 1
                            color: Qt.darker(dButt.bgColor, 1.3)
                        }

                        Behavior on color {
                            ColorAnimation {
                            }
                        }
                    }
                }
            }

        }

        Rectangle {
            width: parent.width - FM.height / 2
            height: 1
            color: ActivPalette.text

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

        }

    }

}
