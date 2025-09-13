/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TOBOEDEVICE_H
#define TOBOEDEVICE_H

#include "tabstractaudiodevice.h"
#include <oboe/Oboe.h>

class TOboeDevice;

class ToboeCallBack : public oboe::AudioStreamDataCallback
{
public:
    ToboeCallBack(TOboeDevice *devParent = nullptr);
    ~ToboeCallBack();

    oboe::DataCallbackResult onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames);

    void terminate();

private:
    TOboeDevice *m_device = nullptr;
    std::atomic<bool> m_terminating{false};
};

/**
 * Android audio back-end
 */
class TOboeDevice : public TabstractAudioDevice
{
    Q_OBJECT

public:
    TOboeDevice(QObject *parent = nullptr);
    ~TOboeDevice();

    void startPlaying() override;
    void startRecording() override;
    void stop() override;

    void setDeviceName(const QString &devName) override;
    QString deviceName() const override;

    void setAudioOutParams() override;

protected:
    void resultMessage(const oboe::Result &result);

private:
    oboe::AudioStreamBuilder *m_oboe = nullptr;
    std::shared_ptr<oboe::AudioStream> m_stream;
    ToboeCallBack m_callBackClass;
};

#endif // TOBOEDEVICE_H
