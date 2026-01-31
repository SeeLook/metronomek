// SPDX-FileCopyrightText: 2020-2022 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QtCore/qstring.h>

/**
 * Android functions requiring invoking native methods through JNI
 */
namespace Tandroid
{

void keepScreenOn(bool on);

void disableRotation(bool disRot);

/**
 * Returns a number of Android API on a hosting device.
 */
int getAPIlevelNr();

bool askForReadPermission();
}
