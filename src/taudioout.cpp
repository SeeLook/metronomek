/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "taudioout.h"
#include "taudiobuffer.h"

#include <QtGui/qguiapplication.h>
#include <QtMultimedia/qaudiooutput.h>
#include <QtCore/qtimer.h>
#include <QtCore/qfile.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qthread.h>

#include <QtCore/qdebug.h>


/*static*/
QStringList TaudioOUT::getAudioDevicesList() {
  QStringList devNamesList;
  QList<QAudioDeviceInfo> devList = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
  for (int i = 0; i < devList.size(); ++i)
    devNamesList << devList[i].deviceName();
  return devNamesList;
}

QString                TaudioOUT::m_devName = QStringLiteral("default");
TaudioOUT*             TaudioOUT::m_instance = nullptr;
/*end static*/



TaudioOUT::TaudioOUT(QObject *parent) :
  QObject(parent),
  ratioOfRate(1),
  m_bufferFrames(256),
  m_sampleRate(48000),
  m_doCrossFade(false),
  m_cross(0.0f),
  m_crossCount(0),
  m_callBackIsBussy(false),
  m_audioOUT(nullptr)
{
  if (m_instance) {
    qDebug() << "Nothing of this kind... TaudioOUT already exist!";
    return;
  }
  m_instance = this;

  connect(this, &TaudioOUT::finishSignal, this, &TaudioOUT::playingFinishedSlot);
}


TaudioOUT::~TaudioOUT()
{
  stop();
  m_devName = QStringLiteral("anything");
  m_instance = 0;
  if (m_audioOUT) {
    delete m_audioOUT;
    delete m_buffer;
  }
  if (m_beatData) {
    delete m_beatData;
    m_beatData = nullptr;
  }
}


void TaudioOUT::init() {
  loadAudioData();
  setAudioOutParams();
}


void TaudioOUT::setAudioOutParams() {
//   if (m_audioParams->OUTdevName != m_devName)
    createOutputDevice();
}


void TaudioOUT::createOutputDevice() {
  m_deviceInfo = QAudioDeviceInfo::defaultOutputDevice();
  auto devList = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
  for (int i = 0; i < devList.size(); ++i) { // find device with name or keep default one
//     if (devList[i].deviceName() == m_audioParams->OUTdevName) {
    if (devList[i].deviceName() == m_devName) {
      m_deviceInfo = devList[i];
      break;
    }
  }
  m_devName = m_deviceInfo.deviceName();
  qDebug() << m_deviceInfo.defaultOutputDevice().deviceName();
  QAudioFormat format;
    format.setChannelCount(1); // Mono
    format.setSampleRate(m_sampleRate);
    format.setSampleType(QAudioFormat::SignedInt);
    format.setSampleSize(16);
    format.setCodec(QStringLiteral("audio/pcm"));
    format.setByteOrder(QAudioFormat::LittleEndian);
  if (!m_deviceInfo.isFormatSupported(format)) {
    qDebug() << "Output Format 48000/16 mono is not supported";
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

  connect(m_buffer, &TaudioBuffer::feedAudio, this, &TaudioOUT::outCallBack, Qt::DirectConnection);
  connect(m_audioOUT, &QAudioOutput::stateChanged, this, &TaudioOUT::stateChangedSlot);
}


void TaudioOUT::loadAudioData() {
#if defined (Q_OS_ANDROID)
  QFile beatFile(QStringLiteral("assets:/Sounds/beat-classic.raw48-16"));
#else
  QFile beatFile(qApp->applicationDirPath() + QLatin1String("/share/metronomek/") + QLatin1String("Sounds/beat-classic.raw48-16"));
#endif
  if (beatFile.exists()) {
    beatFile.open(QIODevice::ReadOnly);
    m_beatSamples = beatFile.size() / 2;
    m_beatData = new qint16[m_beatSamples];
    QDataStream beatStream(&beatFile);
    beatStream.readRawData(reinterpret_cast<char*>(m_beatData), beatFile.size());
  }
}


bool TaudioOUT::play() {
  startPlayingSlot();
  
  return true;
}


void TaudioOUT::startPlayingSlot() {
  if (m_audioOUT->state() != QAudio::ActiveState)
    m_audioOUT->start(m_buffer);
}


void TaudioOUT::outCallBack(char* data, qint64 maxLen, qint64& wasRead) {
  qint16 sample = 0;
  auto out = reinterpret_cast<qint16*>(data);
  for (int i = 0; i < (maxLen / 2); i++) {
    if (m_currSample < m_beatSamples)
      sample = m_beatData[m_currSample];
    else
      sample = 0;
    m_currSample++;
    if (m_currSample >= m_samplPerBeat)
      m_currSample = 0;
    for (int r = 0; r < ratioOfRate; r++)
      *out++ = sample; // left channel
  }
  wasRead = maxLen;
}


void TaudioOUT::stateChangedSlot(QAudio::State state) {
//   qDebug() << state;
  if (state == QAudio::IdleState)
    playingFinishedSlot();
}


void TaudioOUT::playingFinishedSlot() {
  m_audioOUT->stop();
}


void TaudioOUT::stop() {
  playingFinishedSlot();
}

