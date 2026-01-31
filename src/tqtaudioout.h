// SPDX-FileCopyrightText: 2021 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "tabstractaudiodevice.h"
#include <QtMultimedia/qaudio.h>
#include <QtMultimedia/qaudiodeviceinfo.h>

class TaudioBuffer;
class QAudioOutput;

/**
 * @class TqtAudioOut is Android back-end of Metronomek audio
 */
class TqtAudioOut : public TabstractAudioDevice
{
    Q_OBJECT

public:
    TqtAudioOut(QObject *parent = nullptr);
    ~TqtAudioOut();

    static QStringList getAudioDevicesList();

    void stop() override;

    void startPlaying() override;

    void setDeviceName(const QString &devName) override;

    QString deviceName() const override;

    void setAudioOutParams() override;

protected:
    void createOutputDevice();

    void qtCallBack(char *data, qint64 maxLen, qint64 &wasRead);

private:
    static TqtAudioOut *m_instance;
    static QString m_devName;
    QAudioOutput *m_audioOUT = nullptr;
    TaudioBuffer *m_buffer;
    QAudioDeviceInfo m_deviceInfo;
    int m_bufferFrames, m_sampleRate;
};
