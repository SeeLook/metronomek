/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12


Window {
  id: mainWindow

  visibility: GLOB.isAndroid() && GLOB.fullScreen() ? "FullScreen" : "AutomaticVisibility"

  visible: true
  width: GLOB.geometry.width
  height: GLOB.geometry.height
  x: GLOB.geometry.x
  y: GLOB.geometry.y
  title: qsTr("MetronomeK")
  color: activPal.base

  SystemPalette {
    id: activPal
    property color varTempo: "skyblue"
    colorGroup: SystemPalette.Active
  }
  SystemPalette { id: disblPal;  colorGroup: SystemPalette.Disabled }
  FontMetrics { id: fm }

  // controlling tempo
  property int partId: 0
  property int beatNr: 1
  property int nextTempo: 0
  property int meterCount: 0
  property bool inMotion: false /**< state of pendulum */

  property var dialogItem: null
  property bool leanEnough: false // pendulum is leaned out enough to start playing
  property alias counterPressed: countArea.containsPress

  MetroImage {
    id: metro
    anchors.centerIn: parent
    height: Math.min(parent.height, parent.width * 1.536273115220484)
    width: height * imgFactor

    Rectangle { // label of Italian tempo names
      id: tLabel
      x: parent.width * 0.295; y: parent.height * 0.099
      width: parent.width * 0.26; height: parent.height * 0.58
      color: GLOB.valueColor(activPal.text, 90)
      radius: width / 15
      border { width: tLabel.width / 40; color: activPal.button }
      clip: true
      Rectangle { // pendulum shadow
        z: 4
        color: GLOB.alpha(activPal.text, 40)
        width: pendulum.width; height: pendulum.height
        x: pendulum.x - tLabel.x + pendulum.width / 3
        y: pendulum.y - tLabel.y + pendulum.width / 3
        radius: pendulum.radius
        transformOrigin: Item.Bottom
        rotation: pendulum.rotation
      }
    }

    Repeater { // Italian tempo names
      model: GLOB.temposCount()
      Text {
        z: mainWindow.counterPressed && index === SOUND.nameTempoId ? 10 : 1
        scale: mainWindow.counterPressed && index === SOUND.nameTempoId ? 3.5 : 1
        x: Math.max(0, tLabel.x + (index % 2 ? (mainWindow.counterPressed && index === SOUND.nameTempoId ? -width: tLabel.width / 30)
                      : (mainWindow.counterPressed && index === SOUND.nameTempoId ? tLabel.width: tLabel.width * 0.967 - width)))
        y: tLabel.y + (GLOB.tempoName(index).mid / 200.0) * tLabel.height * 0.85 - tLabel.height * 0.11 - height / 2
        text: GLOB.tempoName(index).name; style: Text.Raised; styleColor: activPal.shadow
        width: tLabel.width / 2 - parent.width / 80
        font { pixelSize: tLabel.height / 35; bold: index === SOUND.nameTempoId }
        horizontalAlignment: index % 2 ? Text.AlignLeft : Text.AlignRight
        fontSizeMode: Text.HorizontalFit; minimumPixelSize: tLabel.height / 60
        color: GLOB.valueColor(activPal.base, index === SOUND.nameTempoId ? 30 : 0)
        Behavior on x { NumberAnimation {} }
        Behavior on scale { NumberAnimation {} }
        Behavior on color { ColorAnimation{} }
      }
    }

    MouseArea {
      id: stopArea
      enabled: SOUND.playing
      width: parent.width; height: parent.height * 0.5
      onDoubleClicked: stopMetronome()
    }

    Rectangle {
      id: pendulum
      z: 5
      color: leanEnough ? "green" :
                          (stopArea.containsPress && SOUND.playing ? "red" :
                              (pendArea.dragged ? activPal.base : GLOB.valueColor(activPal.text, GLOB.stationary ? 40 : 0)))
      width: parent.width / 20; height: parent.height * 0.6
      x: parent.width * 0.3969; y: parent.height * 0.132 - width / 2
      radius: width / 2
      transformOrigin: Item.Bottom

      MouseArea {
        id: pendArea
        z: 10
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

      Text {
        id: countW // counterweight
        property int tempo: SOUND.tempo
        z: 15
        font { family: "metronomek"; pixelSize: parent.height * 0.24 }
        color: countArea.containsPress ? GLOB.valueColor(activPal.text, 20) : (SOUND.variableTempo ? activPal.varTempo : activPal.highlight)
        text: "\u00A4"
        anchors.horizontalCenter: parent.horizontalCenter
        y: pendulum.height * 0.65 * ((countW.tempo - 40) / 200)
        Behavior on y { NumberAnimation { id: countAnim } }
        Text { // inner counterweight
          font { family: "metronomek"; pixelSize: pendulum.height * 0.18 }
          color: SOUND.variableTempo ? activPal.varTempo : activPal.highlight
          text: "\u00A4"
          anchors.centerIn: parent
        }
        Text {
          visible: GLOB.countVisible && meterCount && inMotion
          text: meterCount
          y: parent.height * 0.15
          anchors.horizontalCenter: parent.horizontalCenter
          color: activPal.highlightedText
          font { pixelSize: parent.height * 0.5; bold: true }
        }
        MouseArea {
          id: countArea
          enabled: !SOUND.playing || GLOB.stationary
          anchors.fill: parent
          drag.target: countW
          drag.axis: Drag.YAxis
          drag.minimumY: 0; drag.maximumY: pendulum.height * 0.65
          cursorShape: drag.active ? Qt.DragMoveCursor : Qt.ArrowCursor
          onPositionChanged: {
            SOUND.tempo = Math.round((200 * countW.y) / (pendulum.height * 0.65) + 40)
          }
        }
      }
    }

    Rectangle { // cover for lover pendulum end
      color: activPal.text
      z: 20 // over pendulum
      width: parent.width * 0.2; height: parent.width / 27
      x: parent.width * 0.3; y: parent.height * 0.703
    }

    TspinBox {
      id: sb
      editable: false
      height: parent.height * 0.06 //; width: height * 3
      x: parent.width * 0.76 - width; y: parent.height * 0.75
      font { bold: true; }
      from: 40; to: 240
      value: SOUND.tempo
      onValueModified: SOUND.tempo = value
    }

    AbstractButton {
      onPressed: pressAnim.start()
      property bool innerPress: pressAnim.running || pressed
      PauseAnimation { id: pressAnim; duration: 100 }
      scale: innerPress ? 0.9 : 1
      Behavior on scale { NumberAnimation {} }
      background: TipRect { radius: width / 2; raised: !parent.innerPress }
      x: sb.x + (sb.width - width) / 2; y: sb.y + sb.height + metro.height * 0.01
      width: metro.width * 0.13; height: width
      onClicked: {
        if (SOUND.playing)
          stopMetronome()
        else
          startMetronome()
      }
      Rectangle {
        width: parent.height * 0.55; height: width
        anchors.centerIn: parent
        radius: SOUND.playing ? 0 : width / 2
        color: SOUND.playing ? "red" : "green"
      }
    } // MetroImage

    Text {
      x: metro.width * 0.08; y: sb.y + (sb.height - height) / 2
      text: SOUND.getTempoNameById(SOUND.nameTempoId)
      font { pixelSize: metro.height / 40; bold: true }
      style: SOUND.variableTempo ? Text.Outline : Text.Normal
      color: activPal.text; styleColor: activPal.varTempo
    }

    CuteButton {
      id: tapButt
      border { color: activPal.varTempo; width: SOUND.variableTempo ? fm.height / 6 : 0 }
      text: SOUND.variableTempo ? qsTr("Tempo changes") : qsTr("Tap tempo")
      x: metro.width * 0.06; y: sb.y + sb.height + metro.height * 0.01
      height: metro.width * 0.13; width: height * 2.5
      onClicked: {
        if (SOUND.variableTempo) {
            stopMetronome()
            Qt.createComponent("qrc:/TempoPage.qml").createObject(mainWindow)
        } else
            tapTempo()
      }
      focus: true
    }
  }

  MainMenuButton { x: parent.width * 0.01; y: parent.height * 0.01}

  AbstractButton {
    id: cntButt
    x: parent.width - width
    scale: (parent.height * 0.05) / height; transformOrigin: Item.Right
    width: height * 3; height: fm.height * 2
    property var meterDrewer: null
    visible: !meterDrewer || !meterDrewer.visible
    background: Rectangle {
      color: cntButt.pressed ? activPal.button : "transparent"
      radius: height / 6
      Row {
        anchors.centerIn: parent
        spacing: fm.height / 2
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: qsTr("count to") + ":"
          color: activPal.text
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: SOUND.meter > 1 ? SOUND.meter : "--"
          font { pixelSize: fm.height * 1.4; bold: true }
          textFormat: Text.StyledText
          color: activPal.text
        }
      }
    }
    onClicked: {
      if (!meterDrewer)
        meterDrewer = Qt.createComponent("qrc:/MeterDrawer.qml").createObject(mainWindow)
      meterDrewer.open()
    }
  }

  function startMetronome() {
    partId = 0
    beatNr = 1
    SOUND.tempo = SOUND.getTempoForBeat(partId, beatNr)
    meterCount = 0
    timer.toLeft = pendulum.rotation <= 0
    initAnim.to = GLOB.stationary ? 0 : (timer.toLeft ? -25 : 25)
    initAnim.duration = (30000 / SOUND.tempo)
    pendAnim.stop()
    initAnim.start()
    if (SOUND.isPartInfinite(partId))
      nextTempoPop()
  }

  function stopMetronome() {
    SOUND.playing = false;
    finishAnim.to = 0
    finishAnim.duration = (30000 / SOUND.tempo)
    pendAnim.stop()
    finishAnim.start()
    if (SOUND.variableTempo)
      countW.tempo = Qt.binding( function() { return SOUND.tempo } )
  }

  NumberAnimation {
    id: pendAnim
    target: pendulum; property: "rotation"
    duration: 60000 / SOUND.tempo
  }

  NumberAnimation {
    id: initAnim
    target: pendulum; property: "rotation"
    onStarted: inMotion = true
    onStopped: {
      nextTempo = SOUND.getTempoForBeat(partId, beatNr)
      timer.interval = 2 // delay to allow the timer react on starting sound signal
      SOUND.playing = true
    }
  }

  NumberAnimation {
    id: finishAnim
    target: pendulum; property: "rotation"
    to: 0
    onStopped: {
      countAnim.duration = 150
      inMotion = false
    }
  }

  function nextTempoPop() {
    var ntp = Qt.createComponent("qrc:/NextTempoPop.qml").createObject(mainWindow)
    ntp.open()
    ntp.done.connect(function() {
      SOUND.switchInfinitePart()
    })
  }

  Timer {
    id: timer
    running: SOUND.playing && !GLOB.stationary
    repeat: true
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
      var currTime = new Date().getTime()
      if (elap > 0) {
        elap = currTime - elap
        lag += elap - interval
      }
      elap = currTime

      if (GLOB.countVisible)
        meterCount = ((beatNr - 1) % SOUND.meterOfPart(partId)) + 1

      interval = Math.max((60000 / nextTempo) - lag, 1)
      SOUND.tempo = nextTempo
      lag = 0
      toLeft = !toLeft

      beatNr++
      nextTempo = SOUND.getTempoForBeat(partId, beatNr)
      if (nextTempo == 0) {
        partId++
        beatNr = 1
        nextTempo = SOUND.getTempoForBeat(partId, beatNr)
        if (nextTempo == 0) {
            timer.stop()
            stopMetronome()
            return
        } else {
            if (SOUND.isPartInfinite(partId))
              nextTempoPop()
        }
      }
      if (SOUND.variableTempo) {
        countAnim.duration = interval
        countW.tempo = nextTempo
      }
      pendAnim.start()
    }
  }

  Shortcut { id: spaceShort; sequence: " "; enabled: !SOUND.variableTempo; onActivated: tapTempo() }

  property real lastTime: new Date().getTime()

  function tapTempo() {
    var currTime = new Date().getTime()
    if (currTime - lastTime < 2000)
      SOUND.tempo = GLOB.bound(40, Math.round(60000 / (currTime - lastTime)), 240)
      lastTime = currTime
  }

  Component.onCompleted: {
    varTempoSlot()
  }

  Connections {
    target: SOUND
    function onVariableTempoChanged() { varTempoSlot() }
  }

  property var compView: null

  function varTempoSlot() {
    if (SOUND.variableTempo) {
        if (!compView)
          compView = Qt.createComponent("qrc:/CompositionView.qml").createObject(mainWindow.contentItem)
    } else {
        if (compView)
          compView.destroy()
    }
  }

  onClosing: {
    GLOB.geometry = Qt.rect(x ,y, width, height)
    if (GLOB.isAndroid() && dialogItem) {
      close.accepted = false
      dialogItem.destroy()
    }
  }
}
