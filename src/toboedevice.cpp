/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "toboedevice.h"
#include <QtAndroidExtras/qandroidfunctions.h>

#include <QtCore/qdebug.h>


class ToboeCallBack : public oboe::AudioStreamDataCallback {

public:
  ToboeCallBack(TOboeDevice* devParent = nullptr) : oboe::AudioStreamDataCallback(), m_device(devParent) {}
  oboe::DataCallbackResult onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) {
      Q_UNUSED(audioStream)

      unsigned int retVal = 0;
      if (m_device->audioMode() == TabstractAudioDevice::Audio_Output)
        emit m_device->feedAudio(static_cast<char*>(audioData), static_cast<unsigned int>(numFrames), retVal);
      else
        emit m_device->takeAudio(static_cast<char*>(audioData), static_cast<unsigned int>(numFrames), retVal);

      return retVal == 0 ? oboe::DataCallbackResult::Continue : oboe::DataCallbackResult::Stop;
  }

private:
  TOboeDevice           *m_device;

};



TOboeDevice::TOboeDevice(QObject* parent ) :
  TabstractAudioDevice(parent)
{
  m_callBackClass = new ToboeCallBack();
}


TOboeDevice::~TOboeDevice()
{
  if (m_oboe) {
    m_stream->close();
    delete m_oboe;
  }
  if (m_callBackClass)
    delete m_callBackClass;
}



void TOboeDevice::startPlaying() {
  if (m_oboe){
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


void TOboeDevice::startRecording() {
  if (m_oboe) {
    if (audioMode() != Audio_Input) {
      stop();
      m_stream->close();
      if (QtAndroid::androidSdkVersion() >= 23) {
        const QString allowRec("android.permission.RECORD_AUDIO");
        if (QtAndroid::checkPermission(allowRec) != QtAndroid::PermissionResult::Granted) {
          auto perms = QtAndroid::requestPermissionsSync(QStringList() << allowRec);
          qDebug() << allowRec << (perms[allowRec] == QtAndroid::PermissionResult::Granted);
        }
      }
      setAudioType(Audio_Input);
      m_oboe->setDirection(oboe::Direction::Input);
      m_oboe->setChannelCount(oboe::ChannelCount::Mono);
      m_oboe->setInputPreset(oboe::InputPreset::Unprocessed);
      resultMessage(m_oboe->openStream(m_stream));
    }
    m_stream->requestStart();
  }
}

void TOboeDevice::stop() {
  if (m_oboe)
    m_stream->requestStop();
}


void TOboeDevice::setDeviceName(const QString& devName) {
  Q_UNUSED(devName)
  setAudioOutParams();
}


QString TOboeDevice::deviceName() const {
  return QStringLiteral("anything");
}


void TOboeDevice::setAudioOutParams() {
  if (!m_oboe) {
    m_callBackClass = new ToboeCallBack(this);

    m_oboe = new oboe::AudioStreamBuilder();
    m_oboe->setDirection(oboe::Direction::Output);
    m_oboe->setPerformanceMode(oboe::PerformanceMode::LowLatency);
    m_oboe->setSharingMode(oboe::SharingMode::Shared);
    m_oboe->setFormat(oboe::AudioFormat::I16);
    m_oboe->setChannelCount(oboe::ChannelCount::Stereo);
    m_oboe->setSampleRate(sampleRate());
    m_oboe->setDataCallback(m_callBackClass);

    resultMessage(m_oboe->openStream(m_stream));
  }
  // NOTE: to change Oboe params just close stream, set new parameters and open stream again
}


void TOboeDevice::resultMessage(const oboe::Result& result) {
  if (result != oboe::Result::OK)
    qDebug() << "[ToboeAudioOut] Failed to create Oboe" << (audioMode() == Audio_Input ? "INPUT" : "OUTPUT")
             << "stream. Error:" << oboe::convertToText(result);
}
