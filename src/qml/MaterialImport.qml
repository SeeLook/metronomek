// SPDX-FileCopyrightText: 2019-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls.Material

Item {
    Component.onCompleted: {
        mainWindow.Material.accent = ActivPalette.highlight
    }
}
