/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls.Material

Item {
    Component.onCompleted: {
        console.log("MaterialImport", Material.ExtraLargeScale, Material.LargeScale);
        mainWindow.Material.accent = ActivPalette.highlight
    }
}
