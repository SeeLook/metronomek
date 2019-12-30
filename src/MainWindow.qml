/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12

import Metronomek 1.0

Window {
  id: mainWindow

  visible: true
  width: GLOB.geometry.width
  height: GLOB.geometry.height
  x: GLOB.geometry.x
  y: GLOB.geometry.y
  title: qsTr("MetronomeK")
  color: activPal.base

  SystemPalette { id: activPal;  colorGroup: SystemPalette.Active }
  FontMetrics { id: fm }

  property bool leanEnough: false // pendulum is leaned out enough to start playing

  TmetroItem {
//     id: metro
    anchors.fill: parent

    Image {
      id: metro
      anchors.centerIn: parent
      source: "qrc:/bg.png"
      height: Math.min(parent.height, parent.width * 1.529564315352697)
      width: height * (sourceSize.width / sourceSize.height)
      antialiasing: true

      MouseArea {
        id: stopArea
        enabled: SOUND.playing
        width: parent.width; height: parent.height * 0.5
        onPressAndHold: stopMetronome()
      }

      Rectangle {
        id: pendulum
        color: leanEnough ? "green" : (stopArea.containsPress && SOUND.playing ? "red" : (pendArea.dragged ? activPal.highlight : (GLOB.stationary ? "gray" : "black")))
        width: parent.width / 20; y: parent.height * 0.125 - width / 2
        x: parent.width * 0.3969; height: parent.height * 0.61
        radius: width / 2
        transformOrigin: Item.Bottom

        MouseArea {
          id: pendArea
          property bool dragged: false
          enabled: !SOUND.playing
          width: parent.width * 3; height: parent.height; x: -parent.width
          cursorShape: dragged ? Qt.DragMoveCursor : Qt.ArrowCursor
          onPositionChanged: {
            dragged = true
            var dev = mouse.x - width / 2
            pendulum.rotation = (Math.atan(dev / height) * 180) / Math.PI
            leanEnough = Math.abs(dev) > height * 0.2
          }
          onReleased: {
            leanEnough = false
            dragged = false
            if (Math.abs(mouse.x - width / 2) > height * 0.2)
              startMetronome()
            else
              stopMetronome()
          }
        }

        Shape {
          id: countW // counterweight
          width: parent.width * 3; height: parent.width * 3
          y: parent.height * (0.05 + ((SOUND.tempo - 40) / 200) * 0.65)
          anchors.horizontalCenter: parent.horizontalCenter
          ShapePath {
            strokeWidth: pendulum.width / 3
            strokeColor: countArea.containsPress ? activPal.highlight : "black"
            fillColor: "gray"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: 0; startY: 0
            PathLine { x: pendulum.width * 3; y: 0 }
            PathLine { x: pendulum.width * 3; y: pendulum.width * 2 }
            PathLine { x: pendulum.width * 2.5; y: pendulum.width * 3 }
            PathLine { x: pendulum.width * 0.5; y: pendulum.width * 3 }
            PathLine { x: 0; y: pendulum.width * 2 }
            PathLine { x: 0; y: 0 }
          }
          Text {
            visible: SOUND.meter > 1 && GLOB.countVisible && SOUND.playing
            text: SOUND.meterCount + 1
            anchors.centerIn: parent
            color: "white"
            font { pixelSize: parent.height * 0.7; bold: true }
          }
          MouseArea {
            id: countArea
            enabled: !SOUND.playing || GLOB.stationary
            anchors.fill: parent
            drag.target: countW
            drag.axis: Drag.YAxis
            drag.minimumY: pendulum.height * 0.05; drag.maximumY: pendulum.height * 0.7
            cursorShape: drag.active ? Qt.DragMoveCursor : Qt.ArrowCursor
            onPositionChanged: SOUND.tempo = Math.round((countW.y * 200) / (pendulum.height * 0.65) + 25)
          }
        }
      }

      Rectangle { // cover for lover pendulum end
        color: "black"
        width: parent.width * 0.2; height: parent.width / 24
        x: parent.width * 0.3; y: parent.height * 0.703
      }

      SpinBox {
        id: sb
        height: parent.height * 0.06; width: height * 3
        x: parent.width * 0.75 - width; y: parent.height * 0.75
        font { bold: true; }
        from: 40; to: 240
        value: SOUND.tempo
        onValueModified: SOUND.tempo = value
      }

      RoundButton {
        x: sb.x + (sb.width - width) / 2; y: sb.y + sb.height + metro.height * 0.01
        width: metro.width * 0.15; height: width
        radius: width / 2
        onClicked: {
          if (SOUND.playing)
            stopMetronome()
          else
            startMetronome()
        }
        Rectangle {
          width: parent.height * 0.5; height: width
          anchors.centerIn: parent
          radius: SOUND.playing ? 0 : width / 2
          color: SOUND.playing ? "red" : "green"
        }
      }

      RoundButton {
        x: metro.width * 0.06; y: sb.y + sb.height + metro.height * 0.01
        height: metro.width * 0.15; width: height * 2.5
        text: qsTr("Tap tempo")
        onClicked: tapTempo()
        focus: true
      }

      Column {
        x: parent.width * 0.67; y: parent.height * 0.45
        rotation: -30

        Label {
          text: qsTr("count to") + ":"
          anchors.right: parent.right
        }
        RoundButton {
          property var meterDrewer: null
          flat: true
          anchors.horizontalCenter: parent.horizontalCenter
          width: height; height: metro.height * 0.08
          font { pixelSize: height * 0.6; bold: true }
          text: SOUND.meter > 1 ? SOUND.meter : "--"
          onClicked: {
            if (!meterDrewer) {
              var m = Qt.createComponent("qrc:/MeterDrawer.qml")
              meterDrewer = m.createObject(mainWindow)
            }
            meterDrewer.open()
          }
        }
      }
    }
  }

  MainMenuButton { x: parent.width * 0.01; y: parent.height * 0.01}

  function startMetronome() {
    SOUND.meterCount = 0
    timer.toLeft = pendulum.rotation <= 0
    initAnim.to = GLOB.stationary ? 0 : (timer.toLeft ? -25 : 25)
    initAnim.duration = (30000 / SOUND.tempo) * ((25 - Math.abs(pendulum.rotation)) / 25)
    pendAnim.stop()
    initAnim.start()
  }

  function stopMetronome() {
    SOUND.playing = false;
    finishAnim.to = 0
    finishAnim.duration = (30000 / SOUND.tempo) * ((25 - Math.abs(pendulum.rotation)) / 25)
    pendAnim.stop()
    finishAnim.start()
  }

  NumberAnimation {
    id: pendAnim
    target: pendulum; property: "rotation"
    duration: 60000 / SOUND.tempo
  }

  NumberAnimation {
    id: initAnim
    target: pendulum; property: "rotation"
    onStopped: {
      timer.interval = 2 // delay to allow the timer react on starting sound signal
      SOUND.playing = true
    }
  }

  NumberAnimation {
    id: finishAnim
    target: pendulum; property: "rotation"
    to: 0
  }

  Timer {
    id: timer
    running: SOUND.playing && !GLOB.stationary
    repeat: true; triggeredOnStart: true
//     interval: 60000 / SOUND.tempo
    property real elap: 0
    property real lag: 0
    property bool toLeft: true
    onRunningChanged: {
      if (running) {
        elap = 0; lag = 0
      }
    }
    onTriggered: {
      pendAnim.stop()
      pendAnim.to = toLeft ? 25 : -25
      pendAnim.start()
      var currTime = new Date().getTime()
      if (elap > 0) {
        elap = currTime - elap
        lag += elap - interval
      }
      elap = currTime
      interval = Math.max((60000 / SOUND.tempo) - lag, 1)
      lag = 0
      toLeft = !toLeft
    }
  }

  Shortcut { id: spaceShort; sequence: " "; onActivated: tapTempo() }

  property real lastTime: new Date().getTime()

  function tapTempo() {
    var currTime = new Date().getTime()
    if (currTime - lastTime < 1500)
      SOUND.tempo = Math.round(60000 / (currTime - lastTime))
      lastTime = currTime
  }

  onClosing: {
    GLOB.geometry = Qt.rect(x ,y, width, height)
  }
}
