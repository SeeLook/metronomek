/** This file is part of Metronomek                                  *
 * Copyright (C) 2022-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#pragma once

#include <QtCore/qlocale.h>

/**
 * Converts Qt 5 @p QLocale::Language into Qt 6 @p QLocale::Language.
 * Yup, these enumerations differ.
 * Wav files with counting have old 'qtlang' attribute of XML extension
 * with Qt 5 language number.
 * Now we are adding other attribute: 'qt6lang' apparently.
 */
QLocale::Language fromQt5Lang(int qt5lang);
