/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Tdialog {
    id: vCntPage

    // private
    property CountManager cntMan: SOUND.countManager()
    property var progBar: null

    function appendToLocalModel(modelEntry) {
        let wav = modelEntry.split(";");
        localCntsMod.append({
            "langID": wav[0],
            "langName": wav[1],
            "cntName": wav[2]
        });
    }

    function updateOnlineModel() {
        var oMod = cntMan.onlineModel();
        for (var w = 0; w < oMod.length; ++w) {
            let wav = oMod[w].split(";");
            onlineMod.append({
                "langID": wav[0],
                "langName": wav[1] + " / " + wav[2],
                "size": wav[3]
            });
        }
    }

    visible: true
    padding: GLOB.fontSize() / 2
    standardButtons: Dialog.Ok | Dialog.Help
    Component.onCompleted: {
        (footer as DialogButtonBox).standardButton(Dialog.Help).text = GLOB.TR("TempoPage", "Actions");
    }

    onHelpRequested: {
        actMenu.open();
    }

    Connections {
        target: vCntPage.cntMan
        function onAppendToLocalModel(modelEntry: string): void {
            vCntPage.appendToLocalModel(modelEntry);
            localList.positionViewAtEnd();
        }

        function onDownProgress(prog: real): void {
            vCntPage.progBar.indeterminate = false;
            vCntPage.progBar.value = prog;
            if (prog >= 1)
                vCntPage.progBar.destroy(1000);
            else if (prog < 0)
                vCntPage.progBar.destroy();
        }

        function onOnlineModelUpdated() {
            onlineList.model = null;
            onlineMod.clear();
            vCntPage.updateOnlineModel();
            onlineList.model = onlineMod;
            vCntPage.progBar.destroy();
        }
    }

    ListModel {
        id: localCntsMod
    }

    Column {
        ListView {
            id: localList

            width: vCntPage.availableWidth
            height: Math.min(contentHeight, (vCntPage.availableHeight - vCntPage.implicitFooterHeight) / 2 - GLOB.fontSize() * 2)
            spacing: 1
            currentIndex: -1
            model: localCntsMod
            clip: true
            Component.onCompleted: {
                if (localCntsMod.count == 0) {
                    let wavMod = vCntPage.cntMan.countingModelLocal();
                    for (var w = 0; w < wavMod.length; ++w) {
                        vCntPage.appendToLocalModel(wavMod[w]);
                    }
                    localList.positionViewAtIndex(vCntPage.cntMan.localModelId, ListView.Contain);
                }
            }

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: parent.width - GLOB.fontSize()
                height: FM.height * 1.5
                color: ActivPalette.text
                z: 2

                Text {
                    anchors.centerIn: parent
                    color: ActivPalette.base
                    text: qsTr("available sounds of counting")
                }

            }

            ScrollBar.vertical: ScrollBar {
            }

            delegate: DragDelegate {
                id: bgRect

                required property int index
                property var modelData: localCntsMod.get(index)

                dragEnabled: index > 0
                width: parent ? parent.width - GLOB.fontSize(): 0
                height: FM.height * 3
                color: Qt.tint(index % 2 ? ActivPalette.base : ActivPalette.alternateBase, GLOB.alpha(toDel ? "red" : ActivPalette.highlight, pressed || containsMouse ? 80 : (vCntPage.cntMan?.localModelId === index ? 40 : 0)))
                onClicked: vCntPage.cntMan.localModelId = index
                onRemoved: {
                    vCntPage.cntMan.removeLocalWav(index);
                    localCntsMod.remove(index);
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: FM.height / 2

                    Rectangle {
                        width: FM.height * 4.5
                        height: bgRect.height
                        color: vCntPage.cntMan?.localModelId == bgRect.index ? ActivPalette.text : "transparent"
                        radius: height / 2
                        border {
                            width: vCntPage.cntMan?.localModelId == bgRect.index ? GLOB.fontSize() / 5 : 0
                            color: ActivPalette.highlight
                        }

                        Text {
                            anchors.centerIn: parent
                            color: vCntPage.cntMan?.localModelId == bgRect.index ? ActivPalette.base : ActivPalette.text
                            text: bgRect.modelData ? bgRect.modelData.langID : ""

                            font {
                                bold: true
                            }

                        }

                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: bgRect.width - FM.height * 5

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: ActivPalette.text
                            text: bgRect.modelData ? bgRect.modelData.langName : ""
                            font.pixelSize: FM.height
                            minimumPixelSize: FM.height / 2
                            fontSizeMode: Text.HorizontalFit
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: ActivPalette.text
                            text: bgRect.modelData ? bgRect.modelData.cntName : ""
                            font.pixelSize: FM.height * 1.1
                            minimumPixelSize: FM.height * 0.7
                            fontSizeMode: Text.HorizontalFit
                            elide: Text.ElideRight
                        }

                    }

                }

            }

        }

        Item { // spacer
            width: vCntPage.width - GLOB.fontSize()
            height: FM.height / 2
        }

        ListModel {
            id: onlineMod
        }

        ListView {
            id: onlineList

            width: vCntPage.availableWidth
            height: vCntPage.availableHeight - vCntPage.implicitFooterHeight - localList.height - FM.height / 2
            spacing: 1
            clip: true
            currentIndex: -1
            model: onlineMod
            Component.onCompleted: {
                if (onlineMod.count == 0)
                    vCntPage.updateOnlineModel();

            }

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: parent.width - GLOB.fontSize()
                height: FM.height * 1.5
                color: ActivPalette.text
                z: 2

                Row {
                    anchors.centerIn: parent

                    Text {
                        color: ActivPalette.base
                        text: qsTr("sounds of counting to download")
                    }

                }

            }

            delegate: Rectangle {
                id: bgRect2

                required property int index
                property var modelEntry: ListView.view.model.get(index)

                width: parent.width - GLOB.fontSize()
                height: FM.height * 2.5
                color: ma.pressed || ma.containsMouse ? Qt.tint(ActivPalette.base, GLOB.alpha(ActivPalette.highlight, 50)) : (index % 2 ? ActivPalette.base : ActivPalette.alternateBase)

                Text {
                    x: FM.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: ActivPalette.text
                    text: bgRect2.modelEntry.langID

                    font {
                        bold: true
                    }

                }

                Text {
                    x: FM.height * 3.5
                    width: bgRect2.width - FM.height * 9
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                    color: ActivPalette.text
                    text: bgRect2.modelEntry.langName
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: FM.height / 4
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        color: ActivPalette.text
                        text: qsTranslate("QFileSystemModel", "%1 KB").arg(bgRect2.modelEntry.size) + " "
                    }

                    Text {
                        color: ActivPalette.highlight
                        text: "\u00c1"

                        font {
                            family: "Metronomek"
                            pixelSize: FM.height * 1.7
                        }

                    }

                }

                MouseArea {
                    id: ma

                    enabled: !vCntPage.cntMan?.downloading
                    anchors.fill: parent
                    hoverEnabled: !GLOB.isAndroid()
                    onClicked: {
                        vCntPage.cntMan.downloadCounting(bgRect2.index);
                        vCntPage.progBar = progBarComp.createObject(bgRect2);
                    }
                }

            }

            ScrollBar.vertical: ScrollBar {}

        }

    }

    Component {
        id: progBarComp

        ProgressBar {
            width: parent.width - FM.height * 2
            z: 50000
            indeterminate: true

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            CuteButton {
                visible: vCntPage.cntMan.downloading
                width: FM.height * 5
                height: FM.height * 2
                x: parent.width - FM.height * 5
                y: -FM.height * 2
                text: qsTranslate("QPlatformTheme", "Abort")
                bgColor: Qt.tint(ActivPalette.button, GLOB.alpha("red", 40))
                onClicked: vCntPage.cntMan.abortDownload()
            }

        }

    }

    Menu {
        id: actMenu
        y: vCntPage.height - height - vCntPage.implicitFooterHeight
        x: (vCntPage.width - width) / 2
        Component.onCompleted: {
            var maxW = 0;
            for (var m = 0; m < count; ++m) maxW = Math.max(maxW, itemAt(m).width)
            width = Math.min(vCntPage.width - FM.height, maxW + FM.height * 2);
        }

        MenuItem {
            text: qsTr("Prepare own counting out loud")
            onTriggered: Qt.createComponent("Metronomek.Core", "VerbalCountEdit").createObject(mainWindow)
        }

        MenuItem {
            text: qsTr("Update online counting list")
            onTriggered: {
                vCntPage.cntMan.downloadOnlineList();
                vCntPage.progBar = progBarComp.createObject(vCntPage.contentItem);
            }
        }

        MenuItem {
            text: qsTranslate("QShortcut", "Help")
            onTriggered: {
                let hPop = Qt.createComponent("Metronomek.Core", "HelpPop").createObject(mainWindow, {
                    "helpText": qsTr("Matronomek is installed with counting out loud only in English language.") + "<br>" + qsTr("But counting for other languages can be easy obtained:") + "<ul><li>" + qsTr("by downloading files available online (for free)") + "</li><li>" + qsTr("or by recording own counting.") + "</li></ul><br><a href=\"https://metronomek.sourceforge.io\">" + qsTr("Read more online.") + "</a>"
                });
                (hPop as HelpPop).open();
            }
        }
        onOpened: forceActiveFocus();

    }

}
