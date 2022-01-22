/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tqtaudioout.h"
#include "taudiobuffer.h"

#include <QtMultimedia/qaudiooutput.h>
#include <QtCore/qdebug.h>


/*static*/
TqtAudioOut*                TqtAudioOut::m_instance = nullptr;
QString                     TqtAudioOut::m_devName = QStringLiteral("anything");


QStringList TqtAudioOut::getAudioDevicesList() {
  QStringList devNamesList;
  QList<QAudioDeviceInfo> devList = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
  for (int i = 0; i < devList.size(); ++i)
    devNamesList << devList[i].deviceName();
  return devNamesList;
}



TqtAudioOut::TqtAudioOut(QObject* parent) :
  TabstractAudioDevice(parent),
  m_bufferFrames(256),
  m_sampleRate(48000)
{
  m_instance = this;
}


TqtAudioOut::~TqtAudioOut()
{
  m_instance = nullptr;
  if (m_audioOUT) {
    delete m_audioOUT;
    delete m_buffer;
  }
}



void TqtAudioOut::startPlaying() {
  if (m_audioOUT->state() != QAudio::ActiveState)
    m_audioOUT->start(m_buffer);
}


void TqtAudioOut::stopPlaying() {
  m_audioOUT->stop();
}


void TqtAudioOut::setDeviceName(const QString& devName) {
  if (m_devName != devName) {
    m_devName = devName;
    createOutputDevice();
  }
}

QString TqtAudioOut::deviceName() const {
  return QString();
}

void TqtAudioOut::setAudioOutParams() {
  createOutputDevice();
}


void TqtAudioOut::createOutputDevice() {
  m_deviceInfo = QAudioDeviceInfo::defaultOutputDevice();
  auto devList = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
  for (int i = 0; i < devList.size(); ++i) { // find device with name or keep default one
    if (devList[i].deviceName() == m_devName) {
      m_deviceInfo = devList[i];
      break;
    }
  }
  m_devName = m_deviceInfo.deviceName();

  QAudioFormat format;
  format.setChannelCount(2); // stereo
  format.setSampleRate(m_sampleRate);
  format.setSampleType(QAudioFormat::SignedInt);
  format.setSampleSize(16);
  format.setCodec(QStringLiteral("audio/pcm"));
  format.setByteOrder(QAudioFormat::LittleEndian);
  if (!m_deviceInfo.isFormatSupported(format)) {
    qDebug() << "Output Format 48000/16 stereo is not supported";
    format = m_deviceInfo.nearestFormat(format);
    qDebug() << "Format is" << format.sampleRate() << format.channelCount() << format.sampleSize();
  }
  m_sampleRate = format.sampleRate();

  if (m_audioOUT) {
    delete m_audioOUT;
    delete m_buffer;
  }
  m_audioOUT = new QAudioOutput(m_deviceInfo, format, this);
  m_audioOUT->setBufferSize(m_bufferFrames * 2);

  m_buffer = new TaudioBuffer(this);
  m_buffer->open(QIODevice::ReadOnly);
  m_buffer->setBufferSize(m_audioOUT->bufferSize());

  qDebug() << "OUT:" << m_deviceInfo.deviceName() << m_audioOUT->format().sampleRate();

  connect(m_buffer, &TaudioBuffer::feedAudio, this, &TqtAudioOut::qtCallBack, Qt::DirectConnection);
}


void TqtAudioOut::qtCallBack(char *data, qint64 maxLen, qint64 &wasRead) {
  unsigned int retVal = static_cast<unsigned int>(wasRead);
  // divide by 4 (2 bytes for 16 bits sample of 2 stereo channels)
  emit feedAudio(data, static_cast<unsigned int>(maxLen / 4), retVal);
  wasRead = static_cast<qint64>(retVal) * 4; // revert value of processed bytes
}


