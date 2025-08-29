/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tabstractaudiodevice.h"
#include <QtCore/qdebug.h>

TabstractAudioDevice::TabstractAudioDevice(QObject *parent)
    : QObject(parent)
{
}

void TabstractAudioDevice::setSamplaRate(quint32 sr)
{
    if (sr != m_sampleRate) {
        m_sampleRate = sr;
        emit sampleRateChanged();
    }
}

// #################################################################################################
// ###################                PROTECTED         ############################################
// #################################################################################################

void TabstractAudioDevice::setAudioType(TabstractAudioDevice::EaudioMode aMode)
{
    if (m_audioMode != aMode) {
        m_audioMode = aMode;
        emit audioModeChanged();
    }
}
