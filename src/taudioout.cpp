/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "taudioout.h"
#include "taudiobuffer.h"
#include "tglob.h"

#include <QtGui/qguiapplication.h>
#include <QtMultimedia/qaudiooutput.h>
#include <QtCore/qtimer.h>
#include <QtCore/qfile.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qsettings.h>

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
  stopTicking();
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
  GLOB->settings()->setValue(QStringLiteral("beatType"), m_beatType);
}


void TaudioOUT::init() {
  if (m_initialized) {
      qDebug() << "[TaudioOUT] has been initialized already! Skipping.";
      return;
  } else {
      connect(GLOB, &Tglob::tempoChanged, this, [=]{ setTempo(GLOB->tempo()); });
      setTempo(GLOB->tempo());
      setBeatType(qBound(0, GLOB->settings()->value(QStringLiteral("beatType"), 0).toInt(), static_cast<int>(Beat_TypesCount) - 1));
      setAudioOutParams();
  }
}


void TaudioOUT::setAudioOutParams() {
//   if (m_audioParams->OUTdevName != m_devName)
    createOutputDevice();
}


void TaudioOUT::setTempo(int t) {
  m_samplPerBeat = (48000 * 60) / t;
}


void TaudioOUT::setPlaying(bool pl) {
  if (m_playing != pl) {
    if (pl)
      startTicking();
    else
      stopTicking();
  }
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


void TaudioOUT::startTicking() {
  startPlayingSlot();  
}


void TaudioOUT::startPlayingSlot() {
  if (m_audioOUT->state() != QAudio::ActiveState) {
    m_currSample = 0;
    m_audioOUT->start(m_buffer);
  }
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
  if (state == QAudio::IdleState)
    playingFinishedSlot();
  m_playing = state == QAudio::ActiveState;
  emit playingChanged();
}


void TaudioOUT::playingFinishedSlot() {
  m_audioOUT->stop();
}


void TaudioOUT::stopTicking() {
  playingFinishedSlot();
}


void TaudioOUT::setBeatType(int bt) {
  if (bt < 0 || bt > static_cast<int>(Beat_TypesCount) - 1) {
    qDebug() << "[TaudioOUT] Wrong beat type!" << bt << "Restore to classic default.";
    bt = 0;
  }
  if (bt != m_beatType) {
    m_beatType = bt;
#if defined (Q_OS_ANDROID)
    QString beatFileName = QStringLiteral("assets:/Sounds/beat-");
#else
    QString beatFileName = qApp->applicationDirPath() + QLatin1String("/share/metronomek/Sounds/beat-");
#endif
    beatFileName += getBeatFileName(static_cast<EbeatType>(bt)) +  QLatin1String(".raw48-16");
    QFile beatFile(beatFileName);
    if (m_beatData) {
      delete m_beatData;
      m_beatData = nullptr;
    }
    if (beatFile.exists()) {
        beatFile.open(QIODevice::ReadOnly);
        m_beatSamples = beatFile.size() / 2;
        m_beatData = new qint16[m_beatSamples];
        QDataStream beatStream(&beatFile);
        beatStream.readRawData(reinterpret_cast<char*>(m_beatData), beatFile.size());
    } else {
        m_beatSamples = 0;
        qDebug() << "[TaudioOUT] beat file" << beatFileName << "doesn't exist";
    }
    emit beatTypeChanged();
  }
}


QString TaudioOUT::getBeatFileName(TaudioOUT::EbeatType bt) {
  static const char* const beatFileArray[static_cast<int>(Beat_TypesCount)] = {
    "classic", "classic2", "snap", "parapet", "sticks"
  };
  return QString(beatFileArray[static_cast<int>(bt)]);
}


QString TaudioOUT::getBeatName(int bt) {
  if (bt < 0 || bt > beatTypeCount() - 1)
    return QString();
  static const char* const beatNameArr[static_cast<int>(Beat_TypesCount)] = {
    QT_TRANSLATE_NOOP("BeatType", "Metronome beat"), QT_TRANSLATE_NOOP("BeatType", "Metronome beat 2"),
    QT_TRANSLATE_NOOP("BeatType", "Snapping fingers"), QT_TRANSLATE_NOOP("BeatType", "Beating at parapet"),
    QT_TRANSLATE_NOOP("BeatType", "Drum sticks")
  };
  return QGuiApplication::translate("beatType", beatNameArr[bt]);
}
