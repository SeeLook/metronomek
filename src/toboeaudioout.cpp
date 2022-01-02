/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "toboeaudioout.h"

#include <QtCore/qdebug.h>


class ToboeCallBack : public oboe::AudioStreamDataCallback {

public:
  ToboeCallBack(ToboeAudioOut* outParent = nullptr) : oboe::AudioStreamDataCallback(), m_out(outParent) {}
  oboe::DataCallbackResult onAudioReady(oboe::AudioStream *audioStream, void *audioData, int32_t numFrames) {
      Q_UNUSED(audioStream)
      unsigned int retVal = 0;
      emit m_out->feedAudio(static_cast<char*>(audioData), static_cast<unsigned int>(numFrames), retVal);
      return retVal == 0 ? oboe::DataCallbackResult::Continue : oboe::DataCallbackResult::Stop;
  }

private:
  ToboeAudioOut           *m_out;

};



ToboeAudioOut::ToboeAudioOut(QObject* parent ) :
  TabstractAudioOutput(parent)
{
  m_callBackClass = new ToboeCallBack();
}


ToboeAudioOut::~ToboeAudioOut()
{
  if (m_oboe) {
    m_stream->close();
    delete m_oboe;
  }
  if (m_callBackClass)
    delete m_callBackClass;
}



void ToboeAudioOut::startPlaying() {
  if (m_oboe)
    m_stream->requestStart();
}


void ToboeAudioOut::stopPlaying() {
  if (m_oboe)
    m_stream->requestStop();
}


void ToboeAudioOut::setDeviceName(const QString& devName) {
  Q_UNUSED(devName)
  setAudioOutParams();
}


QString ToboeAudioOut::deviceName() const {
  return QStringLiteral("anything");
}


void ToboeAudioOut::setAudioOutParams() {
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

    auto result = m_oboe->openStream(m_stream);
    if (result != oboe::Result::OK)
      qDebug() << "[ToboeAudioOut] Failed to create Oboe stream. Error: %s" << oboe::convertToText(result);
  }
  // NOTE: to change Oboe params just close stream, set new parameters and open stream again
}
