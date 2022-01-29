/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Dialogs 1.2


FileDialog {
  id: beatDialog

  signal beatFile(var beat)

  visible: true
  folder: shortcuts.music
  nameFilters: [ qsTr("Audio WAV") + " (*.wav *.WAV)", qsTr("Raw audio") + " (*.raw *.raw48-16)" ]

  onAccepted: beatFile(beatDialog.fileUrl)
}


