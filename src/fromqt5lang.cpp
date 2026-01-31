// SPDX-FileCopyrightText: 2022-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#include "fromqt5lang.h"

QLocale::Language fromQt5Lang(int qt5lang)
{
    switch (qt5lang) {
    case 30:
        return QLocale::Dutch;
    case 31:
        return QLocale::English;
    case 37:
        return QLocale::French;
    case 42:
        return QLocale::German;
    case 49:
        return QLocale::Hindi;
    case 58:
        return QLocale::Italian;
    case 90:
        return QLocale::Polish;
    case 95:
        return QLocale::Romanian;
    case 96:
        return QLocale::Russian;
    case 129:
        return QLocale::Ukrainian;
    default:
        return QLocale::AnyLanguage;
    }
}
