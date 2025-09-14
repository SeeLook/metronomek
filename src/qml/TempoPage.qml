/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)    *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Tdialog {
    id: tempoPage

    // private
    property SpeedHandler speedHandler: null
    property ComboBox combo: null

    visible: true
    topPadding: GLOB.fontSize() / 2
    bottomPadding: GLOB.fontSize() / 2
    standardButtons: Dialog.Ok | Dialog.Help
    Component.onCompleted: {
        GLOB.dialogItem = tempoPage;
        (footer as DialogButtonBox).standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK");
        (footer as DialogButtonBox).standardButton(Dialog.Help).text = qsTr("Actions");
        speedHandler = SOUND.speedHandler();
        speedHandler.emitAllTempos();
        combo.currentIndex = speedHandler.currCompId;
    }
    onHelpRequested: moreMenu.open()

    ListModel {
        id: tempoModel
    }

    ListView {
        id: changesList

        width: tempoPage.availableWidth
        height: tempoPage.availableHeight
        spacing: 1
        model: tempoModel

        header: ComboBox {
            id: comboEdit

            width: parent.width
            popup.contentItem.width: parent.width
            editable: true
            model: tempoPage.speedHandler ? tempoPage.speedHandler.compositions : null
            textRole: "title"
            Component.onCompleted: tempoPage.combo = this
            onActivated: (index) => {
                tempoPage.speedHandler.setComposition(index);
                displayText = currentText;
            }
            onAccepted: {
                displayText = editText;
                tempoPage.speedHandler.setTitle(editText);
            }
        }

        delegate: TempoPartDelegate {
            id: tpDelegate
            required property TempoPart modelData
            tp: modelData
            onClicked: {
                pop.tp = tp;
                if (pop.height < tempoPage.height / 2) {
                    var p = tpDelegate.mapToItem(tempoPage.contentItem, 0, y + height + FM.height / 2);
                    if (p.y > tempoPage.height - pop.height - FM.height / 2)
                        pop.y = p.y - pop.height - height - FM.height;
                    else
                        pop.y = p.y;
                    pop.x = (tempoPage.width - pop.width) / 2;
                }
                pop.open();
            }
        }

        footer: Column {
            width: parent.width
            spacing: FM.height / 2

            Button {
                width: parent.width
                text: qsTr("Add tempo change")
                onClicked: tempoPage.speedHandler.addTempo()
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: ActivPalette.text
                wrapMode: Text.WordWrap
                text: qsTr("Tap or click to edit tempo change.") + "<br><font color=\"red\">" + qsTr("Drag the item left or right to remove it.")
            }

        }

    }

    Connections {
        function onAppendTempoChange(tp) {
            tempoModel.append({
                "tempoPart": tp
            });
        }

        function onRemoveTempoChange(tpId) {
            tempoModel.remove(tpId);
        }

        function onClearAllChanges() {
            tempoModel.clear();
        }

        target: tempoPage.speedHandler
    }

    Menu {
        id: moreMenu

        y: tempoPage.height - height - tempoPage.implicitFooterHeight
        x: tempoPage.width - width - FM.height

        MenuItem {
            text: qsTr("New composition")
            onClicked: {
                tempoPage.speedHandler.newComposition();
                tempoPage.combo.currentIndex = tempoPage.combo.count - 1;
            }
        }

        MenuItem {
            text: qsTr("Duplicate")
            onClicked: {
                tempoPage.speedHandler.duplicateComposition();
                tempoPage.combo.currentIndex = tempoPage.combo.count - 1;
            }
        }
        //MenuItem {

        //text: qsTranslate("QFileDialog", "Open")
        //}
        //MenuItem {
        //text: qsTranslate("QFileDialog", "Save As")
        //}
        MenuItem {
            text: qsTranslate("QPlatformTheme", "Reset")
            onClicked: {
                var c = changesList.count - 1;
                for (var t = c; t > 0; --t) {
                    let it = changesList.itemAtIndex(t);
                    (it as TempoPartDelegate).toDel = false;
                    (it as TempoPartDelegate).rmAnim.duration = 150 + (c - t) * 25;
                    (it as TempoPartDelegate).rmAnim.to = -it.width;
                    (it as TempoPartDelegate).rmAnim.start();
                }
                (changesList.itemAtIndex(0) as TempoPartDelegate).tp.reset();
                var titl = tempoPage.speedHandler.getTitle(tempoPage.combo.currentIndex + 1);
                tempoPage.speedHandler.setTitle(titl);
                tempoPage.combo.displayText = titl;
            }
        }

        MenuItem {
            text: qsTranslate("QFileDialog", "Remove")
            enabled: tempoPage.combo.count > 1
            onClicked: {
                tempoPage.speedHandler.removeComposition(false);
                tempoPage.combo.currentIndex = 0;
                tempoPage.combo.displayText = tempoPage.combo.currentText;
            }
        }

    }

    Dialog {
        id: pop

        property TempoPart tp: null
        property real extraH: topPadding + bottomPadding + implicitFooterHeight + hdrRect.height

        height: Math.min(extraH + tCol.height, tempoPage.height)
        width: tCol.width + leftPadding + rightPadding
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        header: Rectangle {
            id: hdrRect
            width: pop.width
            height: GLOB.isAndroid() ? radius * 2 : FM.height * 2
            color: ActivPalette.text
            radius: GLOB.isAndroid() ? 28 : FM.height / 2
            Rectangle {
                width: parent.width
                height: hdrRect.radius
                y: parent.height - height
                color: ActivPalette.text
            }
            Text {
                text: pop.tp ? pop.tp.tempoText : ""
                anchors.fill: parent
                padding: FM.height / 8
                font.pixelSize: height
                minimumPixelSize: FM.height / 2
                fontSizeMode: Text.Fit
                textFormat: Text.StyledText
                elide: Text.ElideRight
                color: ActivPalette.base
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }


        background: TipRect {
            radius: hdrRect.radius
        }
        Component.onCompleted: {
            contentItem.clip = true;
            (footer as DialogButtonBox).standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK");
        }

        Flickable {
            height: Math.min(tCol.height + FM.height, tempoPage.height - pop.extraH)
            width: tCol.width
            contentHeight: tCol.height
            contentWidth: tCol.width
            clip: true

            Column {
                id: tCol

                spacing: GLOB.fontSize() / 2
                padding: GLOB.fontSize() / 4

                Grid {
                    id: tempoGrid
                    columns: tempoPage.width < initCtrl.width + targetCtrl.width ? 1 : 2
                    spacing: GLOB.fontSize()
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: 10

                    TempoEdit {
                        id: initCtrl

                        text: qsTr("initial tempo").replace(" ", "<br>")
                        tempo: pop.tp ? pop.tp.initTempo : 40
                        onTempoModified: (t) => {
                            if (pop.tp) {
                                pop.tp.initTempo = t;
                            }
                        }
                    }

                    TempoEdit {
                        id: targetCtrl

                        text: qsTr("target tempo").replace(" ", "<br>")
                        tempo: pop.tp ? pop.tp.targetTempo : 40
                        onTempoModified: (t) => {
                            if (pop.tp) {
                                pop.tp.targetTempo = t;
                            }
                        }
                    }

                }

                Row {
                    spacing: GLOB.fontSize()
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Meter")
                        color: ActivPalette.text
                    }

                    SpinBox {
                        editable: true
                        anchors.verticalCenter: parent.verticalCenter
                        from: 1
                        to: 12
                        value: pop.tp ? pop.tp.meter : 4
                        onValueModified: pop.tp.meter = value
                    }

                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: GLOB.fontSize() * 2

                    Text {
                        enabled: infiChB.enabled
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Duration")
                        color: enabled ? ActivPalette.text : DisblPalette.text
                        font.bold: true
                    }

                    CheckBox {
                        id: infiChB

                        enabled: pop.tp && pop.tp.initTempo === pop.tp.targetTempo
                        anchors.verticalCenter: parent.verticalCenter
                        checked: pop.tp && pop.tp.infinite
                        onToggled: pop.tp.infinite = checked
                        text: "<font color=\"%1\">".arg(enabled ? ActivPalette.text : DisblPalette.text) + qsTr("infinite") + "</font>"
                    }

                }

                Grid {
                    enabled: !infiChB.checked
                    spacing: GLOB.fontSize()
                    columns: tempoPage.width < barCol.width + beatCol.width + secCol.width ? 1 : 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column {
                        id: barCol

                        SpinBox {
                            id: barsSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 1000
                            value: pop.tp ? pop.tp.bars : 1
                            onValueModified: pop.tp.bars = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("bars", "", barsSpin.value), barsSpin.value)
                            color: enabled ? ActivPalette.text : DisblPalette.text
                        }

                    }

                    Column {
                        id: beatCol

                        SpinBox {
                            id: beatsSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 12000
                            value: pop.tp ? pop.tp.beats : 1
                            onValueModified: pop.tp.beats = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("beats", "", beatsSpin.value), beatsSpin.value)
                            color: enabled ? ActivPalette.text : DisblPalette.text
                        }

                    }

                    Column {
                        id: secCol

                        SpinBox {
                            id: secSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 3600
                            value: pop.tp ? pop.tp.seconds : 1
                            onValueModified: pop.tp.seconds = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("seconds", "", secSpin.value), secSpin.value)
                            color: enabled ? ActivPalette.text : DisblPalette.text
                        }

                    }

                }

            }
            // Flickable
        }

        enter: Transition {
            NumberAnimation {
                property: "scale"
                from: 0
                to: 1
            }

        }

        exit: Transition {
            NumberAnimation {
                property: "scale"
                to: 0
            }

        }

    }

}
