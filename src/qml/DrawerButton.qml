/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Controls 2.12

AbstractButton {
    id: dButt

    property color bgColor: activPal.window
    property bool innerPress: pressAnim.running || pressed

    implicitWidth: parent.width
    implicitHeight: fm.height * 2.4
    onPressed: pressAnim.start()
    focusPolicy: Qt.NoFocus

    PauseAnimation {
        id: pressAnim

        duration: 100
    }

    background: Rectangle {
        color: innerPress ? activPal.highlight : activPal.window

        Text {
            width: parent.width - (dButt.checkable ? (chLoader.item ? chLoader.item.width : 0) : 0)
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: fm.height
            text: dButt.text
            font.pixelSize: fm.height * 0.9
            minimumPixelSize: fm.height / 2
            fontSizeMode: Text.Fit
            textFormat: Text.StyledText
            elide: Text.ElideRight
            color: innerPress ? activPal.highlightedText : activPal.text
        }

        Loader {
            id: chLoader

            active: dButt.checkable

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            sourceComponent: CheckBox {
                id: chB

                checkable: true
                checked: dButt.checked
                scale: innerPress ? 0.8 : 1
                onToggled: {
                    dButt.toggle();
                    dButt.toggled();
                }

                Behavior on scale {
                    NumberAnimation {
                    }

                }

                indicator: TipRect {
                    color: bgColor
                    x: -width / 10
                    y: (parent.height - height) / 2
                    width: fm.height * 1.6
                    height: width

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: width
                        radius: width / 8
                        color: chB.checked ? bgColor : activPal.base

                        border {
                            width: chB.checked ? 0 : 1
                            color: Qt.darker(bgColor, 1.3)
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
            width: parent.width - fm.height / 2
            height: 1
            color: activPal.text

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

        }

    }

}
