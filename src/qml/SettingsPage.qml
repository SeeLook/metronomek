/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Tdialog {
    id: settPage

    padding: GLOB.fontSize() / 2
    visible: true
    standardButtons: Dialog.Cancel | Dialog.Apply
    onApplied: {
        GLOB.lang = langTumb.currentIndex === 0 ? "" : langModel.get(langTumb.currentIndex).flag;
        if (outCombo.count > 1)
            SOUND.setDeviceName(outCombo.currentText);

        if (GLOB.isAndroid()) {
            GLOB.keepScreenOn(andSettLoader.item.scrOn);
            GLOB.setDisableRotation(andSettLoader.item.noRotation);
            mainWindow.visibility = andSettLoader.item.fullScr ? "FullScreen" : "AutomaticVisibility";
            GLOB.setFullScreen(andSettLoader.item.fullScr);
        }
        close();
    }
    Component.onCompleted: {
        mainWindow.dialogItem = settPage;
        for (var i = 0; i < langModel.count; ++i) {
            if (langModel.get(i).flag === GLOB.lang || (i == 0 && GLOB.lang === "")) {
                langTumb.currentIndex = i;
                break;
            }
        }
        footer.standardButton(Dialog.Cancel).text = qsTranslate("QPlatformTheme", "Cancel");
        footer.standardButton(Dialog.Apply).text = qsTranslate("QPlatformTheme", "Apply");
    }

    Flickable {
        // Column

        width: parent.width
        height: parent.height
        clip: true
        contentWidth: parent.width
        contentHeight: col.height

        Column {
            id: col

            width: settPage.contentItem.width
            spacing: GLOB.fontSize()

            Frame {
                width: GLOB.fontSize() * (GLOB.isAndroid() ? 25 : 34)
                height: GLOB.fontSize() * (GLOB.isAndroid() ? 7 : 9)
                anchors.horizontalCenter: parent.horizontalCenter

                ListModel {
                    id: langModel

                    ListElement {
                        flag: "default"
                        lang: QT_TR_NOOP("default")
                    }

                    ListElement {
                        flag: "pl"
                        lang: "polski"
                    }

                    ListElement {
                        flag: "us"
                        lang: "English"
                    }

                }

                Tumbler {
                    id: langTumb

                    width: parent.width
                    height: GLOB.fontSize() * (GLOB.isAndroid() ? 6 : 8)
                    visibleItemCount: Math.min(((width / (GLOB.fontSize() * (GLOB.isAndroid() ? 5.5 : 7))) / 2) * 2 - 1, 3)
                    model: langModel

                    Rectangle {
                        z: -1
                        width: parent.height * 1.1
                        height: parent.height * 0.98
                        x: (parent.width - width) / 2
                        y: -parent.height * 0.01
                        color: GLOB.alpha(activPal.highlight, 100)
                        radius: width / 12
                    }

                    delegate: Component {
                        Column {
                            spacing: GLOB.fontSize() / 4
                            opacity: 1 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                            scale: 1.7 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                            z: 1

                            Image {
                                source: "qrc:flags/" + flag + ".png"
                                height: langTumb.height * 0.375
                                width: height * (sourceSize.height / sourceSize.width)
                                anchors.horizontalCenter: parent.horizontalCenter

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: langTumb.currentIndex = index
                                }

                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: flag === "default" ? qsTr(lang) : lang
                                color: activPal.text

                                font {
                                    bold: langTumb.currentIndex === index
                                    pixelSize: langTumb.height * 0.1
                                }

                            }

                        }

                    }

                    contentItem: PathView {
                        id: pathView

                        model: langTumb.model
                        delegate: langTumb.delegate
                        clip: true
                        pathItemCount: langTumb.visibleItemCount + 1
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        dragMargin: width / 2

                        path: Path {
                            startX: 0
                            startY: GLOB.fontSize() * (GLOB.isAndroid() ? 2 : 2.2)

                            PathLine {
                                x: pathView.width
                                y: GLOB.fontSize() * (GLOB.isAndroid() ? 2 : 2.2)
                            }

                        }

                    }

                }

            }

            Text {
                width: parent.width - GLOB.fontSize()
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                text: qsTr("Language change requires restarting the application!")
                color: "red"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: GLOB.fontSize()
                visible: outCombo.count > 1 // only when there are more devices to choose

                Label {
                    id: sndLabel

                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Sound device").replace(" ", "<br>")
                    textFormat: Text.StyledText
                }

                ComboBox {
                    id: outCombo

                    anchors.verticalCenter: parent.verticalCenter
                    width: settPage.contentItem.width - sndLabel.width - GLOB.fontSize() * 2
                    model: SOUND.getAudioDevicesList()
                    Component.onCompleted: {
                        outCombo.currentIndex = outCombo.find(SOUND.outputName());
                    }
                }

            }

            Loader {
                id: andSettLoader

                sourceComponent: GLOB.isAndroid() ? andSettComp : undefined
                anchors.horizontalCenter: parent.horizontalCenter
            }

            CuteButton {
                //           settPage.close()

                width: settPage.width * 0.6
                height: fm.height * 2.5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTranslate("MainDrawerContent", "Verbal count")
                onClicked: {
                    SOUND.createCountingManager(); // create it, if it doesn't exist
                    Qt.createComponent("qrc:/VerbalCountPage.qml").createObject(mainWindow);
                }
            }

        }
        // Flickable

        ScrollBar.vertical: ScrollBar {
            active: true
            visible: true
        }

    }

    Component {
        id: andSettComp

        Column {
            property alias scrOn: screenOnChB.checked
            property alias noRotation: disRotatChB.checked
            property alias fullScr: fullScrChB.checked

            spacing: GLOB.fontSize() / 2

            CheckBox {
                id: screenOnChB

                text: qsTr("keep screen on")
                checked: GLOB.isKeepScreenOn()
            }

            CheckBox {
                id: disRotatChB

                text: qsTr("disable screen rotation")
                checked: GLOB.disableRotation()
            }

            CheckBox {
                id: fullScrChB

                text: qsTr("use full screen")
                checked: GLOB.fullScreen()
            }

        }

    }

}
