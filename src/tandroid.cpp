/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tandroid.h"

#include <QtCore/qcoreapplication.h>
#include <QtCore/qdebug.h>
#include <QtCore/qjniobject.h>
#include <QtCore/qpermissions.h>

void Tandroid::keepScreenOn(bool on)
{
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([on] {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid()) {
            QJniEnvironment env;
            QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

            if (window.isValid()) {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on)
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                else
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
            }
        }
    });
}

void Tandroid::disableRotation(bool disRot)
{
    int orientation = disRot ? 1 : 10; // SCREEN_ORIENTATION_PORTRAIT or SCREEN_ORIENTATION_FULL_SENSOR
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([orientation] {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
            activity.callMethod<void>("setRequestedOrientation", "(I)V", orientation);
    });
}

int Tandroid::getAPIlevelNr()
{
    return QNativeInterface::QAndroidApplication::sdkVersion();
}

bool Tandroid::askForReadPermission()
{
    return true; // TODO
}
