// SPDX-FileCopyrightText: 2021-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
