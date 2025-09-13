/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "toboedevice.h"
#include <QtCore/qcoreapplication.h>
#include <QtCore/qpermissions.h>

#include <QtCore/qdebug.h>

ToboeCallBack::ToboeCallBack(TOboeDevice *devParent)
    : oboe::AudioStreamDataCallback()
    , m_device(devParent)
{
}

ToboeCallBack::~ToboeCallBack() { };

oboe::DataCallbackResult ToboeCallBack::onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames)
{
    Q_UNUSED(audioStream)

    if (m_terminating.load(std::memory_order_acquire)) {
        qDebug() << "[ToboeCallBack] Terminating... Ignore data";
        return oboe::DataCallbackResult::Stop;
    }

    unsigned int retVal = 0;
    if (m_device->audioMode() == TabstractAudioDevice::Audio_Output)
        emit m_device->feedAudio(static_cast<char *>(audioData), static_cast<unsigned int>(numFrames), &retVal);
    else
        emit m_device->takeAudio(static_cast<char *>(audioData), static_cast<unsigned int>(numFrames), &retVal);

    return retVal == 0 ? oboe::DataCallbackResult::Continue : oboe::DataCallbackResult::Stop;
}

void ToboeCallBack::terminate()
{
    m_terminating.store(true, std::memory_order_release);
}

TOboeDevice::TOboeDevice(QObject *parent)
    : TabstractAudioDevice(parent)
    , m_callBackClass(this)
{
}

TOboeDevice::~TOboeDevice()
{
    m_callBackClass.terminate();
    if (m_stream) {
        m_stream->requestStop();
        auto current = m_stream->getState();
        oboe::StreamState next;
        constexpr int64_t timeoutNanos = 500 * 1000 * 1000; // 500 ms
        m_stream->waitForStateChange(current, &next, timeoutNanos);
        m_stream->close();
        m_stream = nullptr;
    }
}

void TOboeDevice::startPlaying()
{
    if (m_oboe) {
        if (audioMode() != Audio_Output) {
            stop();
            m_stream->close();
            setAudioType(Audio_Output);
            m_oboe->setDirection(oboe::Direction::Output);
            m_oboe->setChannelCount(oboe::ChannelCount::Stereo);
            resultMessage(m_oboe->openStream(m_stream));
        }
        m_stream->requestStart();
    }
}

void TOboeDevice::startRecording()
{
    if (!m_oboe)
        return;

    if (audioMode() == Audio_Input) {
        m_stream->requestStart();
        return;
    }

    stop();
    m_stream->close();
    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 23) {
        QMicrophonePermission microphonePermission;
        switch (qApp->checkPermission(microphonePermission)) {
        case Qt::PermissionStatus::Undetermined:
            qApp->requestPermission(microphonePermission, this, &TOboeDevice::startRecording);
            return;
        case Qt::PermissionStatus::Denied:
            // TODO: some info dialog maybe
            return;
        case Qt::PermissionStatus::Granted:
            break;
        }
    }
    setAudioType(Audio_Input);
    m_oboe->setDirection(oboe::Direction::Input);
    m_oboe->setChannelCount(oboe::ChannelCount::Mono);
    m_oboe->setInputPreset(oboe::InputPreset::Generic);
    resultMessage(m_oboe->openStream(m_stream));
}

void TOboeDevice::stop()
{
    if (m_oboe)
        m_stream->requestStop();
}

void TOboeDevice::setDeviceName(const QString &devName)
{
    Q_UNUSED(devName)
    // setAudioOutParams();
}

QString TOboeDevice::deviceName() const
{
    return QStringLiteral("anything");
}

void TOboeDevice::setAudioOutParams()
{
    if (!m_oboe) {
        m_oboe = new oboe::AudioStreamBuilder();
        m_oboe->setDirection(oboe::Direction::Output);
        m_oboe->setPerformanceMode(oboe::PerformanceMode::LowLatency);
        m_oboe->setSharingMode(oboe::SharingMode::Shared);
        m_oboe->setFormat(oboe::AudioFormat::I16);
        m_oboe->setChannelCount(oboe::ChannelCount::Stereo);
        m_oboe->setSampleRate(sampleRate());
        m_oboe->setDataCallback(&m_callBackClass);

        resultMessage(m_oboe->openStream(m_stream));
    }
    // NOTE: to change Oboe params just close stream, set new parameters and open stream again
}

void TOboeDevice::resultMessage(const oboe::Result &result)
{
    if (result != oboe::Result::OK)
        qDebug() << "[ToboeAudioOut] Failed to create Oboe" << (audioMode() == Audio_Input ? "INPUT" : "OUTPUT")
                 << "stream. Error:" << oboe::convertToText(result);
}
