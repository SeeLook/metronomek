/** This file is part of Metronomek                                  *
 * Copyright (C) 2020 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "tandroid.h"
#include <QtAndroidExtras/qandroidfunctions.h>
#include <QtAndroidExtras/qandroidjnienvironment.h>

#include <QtCore/qdebug.h>


void Tandroid::keepScreenOn(bool on) {
  QtAndroid::runOnAndroidThread([on]{
    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid()) {
      QAndroidJniObject window =
          activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

      if (window.isValid()) {
        const int FLAG_KEEP_SCREEN_ON = 128;
        if (on)
          window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
        else
          window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
      }
    }
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck())
      env->ExceptionClear();
  });
}


void Tandroid::disableRotation(bool disRot) {
  int orientation = disRot ? 1 : 10; // SCREEN_ORIENTATION_PORTRAIT or SCREEN_ORIENTATION_FULL_SENSOR
  QtAndroid::runOnAndroidThread([orientation]{
    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
      activity.callMethod<void>("setRequestedOrientation" , "(I)V", orientation);
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck())
      env->ExceptionClear();
  });
}

int Tandroid::getAPIlevelNr() {
  return  QtAndroid::androidSdkVersion();
}
