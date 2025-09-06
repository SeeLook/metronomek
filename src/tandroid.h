/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TANDROID_H
#define TANDROID_H

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

#endif // TANDROID_H
