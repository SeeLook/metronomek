/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)     *
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
#include <QtCore/qmath.h>

#include <QtCore/qdebug.h>


//#################################################################################################
//###################                TsoundData        ############################################
//#################################################################################################

TsoundData::TsoundData(const QString& rawFileName)
{
  if (!rawFileName.isEmpty())
    setFile(rawFileName);
}


TsoundData::~TsoundData()
{
  deleteData();
}


void TsoundData::deleteData()  {
  if (m_data && m_size) {
    delete m_data;
    m_data = nullptr;
    m_size = 0;
  }
}


void TsoundData::setFile(const QString& rawFileName) {
  deleteData();
  if (rawFileName.isEmpty())
    return;

  QFile rawFile(rawFileName);
  if (rawFile.exists()) {
      rawFile.open(QIODevice::ReadOnly);
      m_size = static_cast<int>(rawFile.size() / 2);
      m_data = new qint16[m_size];
      QDataStream beatStream(&rawFile);
      beatStream.readRawData(reinterpret_cast<char*>(m_data), m_size * 2);
  } else {
      m_size = 0;
      qDebug() << "[TaudioOUT] sound file" << rawFileName << "doesn't exist";
  }
}

//#################################################################################################
//###################                TaudioOUT         ############################################
//#################################################################################################

/*static*/
QStringList TaudioOUT::getAudioDevicesList() {
  QStringList devNamesList;
  QList<QAudioDeviceInfo> devList = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
  for (int i = 0; i < devList.size(); ++i)
    devNamesList << devList[i].deviceName();
  return devNamesList;
}


/**
 * Dirty mixing of two given samples
 */
qint16 mix(qint16 sampleA, qint16 sampleB) {
  qint32 a32 = static_cast<qint32>(sampleA), b32 = static_cast<qint32>(sampleB);
  if (sampleA < 0 && sampleB < 0 )
    return static_cast<qint16>((a32 + b32) - ((a32 * b32) / INT16_MIN));
  else if (sampleA > 0 && sampleB > 0 )
    return static_cast<qint16>((a32 + b32) - ((a32 * b32) / INT16_MAX));
  else
    return sampleA + sampleB;
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
  QTimer::singleShot(500, this, [=]{ init(); });
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
  GLOB->settings()->setValue(QStringLiteral("beatType"), m_beatType);
  GLOB->settings()->setValue(QStringLiteral("meter"), m_meter);
  GLOB->settings()->setValue(QStringLiteral("doRing"), m_doRing);
  GLOB->settings()->setValue(QStringLiteral("tempo"), m_tempo);
  GLOB->settings()->setValue(QStringLiteral("ringType"), m_ringType);
}


void TaudioOUT::init() {
  if (m_initialized) {
      qDebug() << "[TaudioOUT] has been initialized already! Skipping.";
      return;
  } else {
      setTempo(qBound(40, GLOB->settings()->value(QStringLiteral("tempo"), 60).toInt(), 240));
      setBeatType(qBound(0, GLOB->settings()->value(QStringLiteral("beatType"), 0).toInt(), beatTypeCount() - 1));
      setMeter(qBound(0, GLOB->settings()->value(QStringLiteral("meter"), 4).toInt(), 12));
      setRingType(qBound(0, GLOB->settings()->value(QStringLiteral("ringType"), 0).toInt(), ringTypeCount() - 1));
      setRing(GLOB->settings()->value(QStringLiteral("doRing"), false).toBool());
      setAudioOutParams();
  }
}


void TaudioOUT::setAudioOutParams() {
//   if (m_audioParams->OUTdevName != m_devName)
    createOutputDevice();
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
    m_meterCount = 0;
    m_offsetCounter = 0.0;
    m_missingSampleNr = 0;
    m_audioOUT->start(m_buffer);
  }
}

/**
 * When @p m_offsetSample is greater than 0 - means length of single beat @p m_samplPerBeat (samples number)
 * is not exactly as tempo so after some (plenty) ticks it will shift in real time.
 * To avoid that @p m_missingSampleNr adds single sample length to @p m_samplPerBeat
 * every whole integer summed with @p m_offsetSample
 */
void TaudioOUT::outCallBack(char* data, qint64 maxLen, qint64& wasRead) {
  qint16 sample = 0;
  auto out = reinterpret_cast<qint16*>(data);
  for (int i = 0; i < (maxLen / 2); i++) {
    sample = m_beat.sampleAt(m_currSample);
    m_currSample++;
    if (m_currSample >= m_samplPerBeat + m_missingSampleNr) {
      m_currSample = 0;
      m_meterCount++;
      if (m_offsetSample != 0.0) {
        m_offsetCounter += m_offsetSample;
        if (m_offsetCounter > 1.0) {
            m_missingSampleNr = qFloor(m_offsetCounter);
            m_offsetCounter = m_offsetCounter - static_cast<qreal>(m_missingSampleNr);
        } else {
            m_missingSampleNr = 0;
        }
      }
      if (m_meterCount == m_meter) {
        if (m_meter > 1 && m_doRing) { // ring a bell
          m_ring.resetPos();
          m_doBell = true;
        }
        m_meterCount = 0;
      }
      emit meterCountChanged();
    }
    if (m_doBell) {
      if (sample)
        sample = mix(sample, m_ring.readSample());
      else
        sample = m_ring.readSample();
      if (m_ring.pos() >= m_ring.size()) {
        m_doBell = false;
      }
    }
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
    m_beat.setFile(getRawFilePath(QLatin1String("beat-") + getBeatFileName(static_cast<EbeatType>(bt))));
    emit beatTypeChanged();
  }
}


QString TaudioOUT::getBeatFileName(TaudioOUT::EbeatType bt) {
  static const char* const beatFileArray[static_cast<int>(Beat_TypesCount)] = {
    "classic", "classic2", "snap", "parapet", "sticks", "sticks2", "clap", "guitar",
    "drum1", "drum2", "drum3", "basedrum", "snaredrum"
  };
  return QString(beatFileArray[static_cast<int>(bt)]);
}


QString TaudioOUT::getBeatName(int bt) {
  if (bt < 0 || bt > beatTypeCount() - 1)
    return QString();
  static const char* const beatNameArr[static_cast<int>(Beat_TypesCount)] = {
    QT_TRANSLATE_NOOP("BeatType", "Metronome beat"), QT_TRANSLATE_NOOP("BeatType", "Metronome beat 2"),
    QT_TRANSLATE_NOOP("BeatType", "Snapping fingers"), QT_TRANSLATE_NOOP("BeatType", "Beating at parapet"),
    QT_TRANSLATE_NOOP("BeatType", "Drum sticks"), QT_TRANSLATE_NOOP("BeatType", "Drum sticks 2"),
    QT_TRANSLATE_NOOP("BeatType", "Clapping"), QT_TRANSLATE_NOOP("BeatType", "Guitar body"),
    QT_TRANSLATE_NOOP("BeatType", "Drum 1"), QT_TRANSLATE_NOOP("BeatType", "Drum 2"), QT_TRANSLATE_NOOP("BeatType", "Drum 3"),
    QT_TRANSLATE_NOOP("BeatType", "Base Drum"), QT_TRANSLATE_NOOP("BeatType", "Snare drum")
  };
  return QGuiApplication::translate("BeatType", beatNameArr[bt]);
}


void TaudioOUT::setRingType(int rt) {
  if (rt < 0 || rt > ringTypeCount() - 1) {
    qDebug() << "[TaudioOUT] Wrong ring type!" << rt << "Set to none.";
    rt = 0;
  }
  if (rt != m_ringType) {
    m_ringType = rt;
    if (m_ringType == 0)
      m_ring.setFile(QString());
    else
      m_ring.setFile(getRawFilePath(QLatin1String("ring-") + getRingFileName(static_cast<EringType>(rt))));
    emit ringTypeChanged();
  }
}


QString TaudioOUT::getRingFileName(TaudioOUT::EringType rt) {
  static const char* const ringFileArray[static_cast<int>(Ring_TypesCount)] = {
    "", "bell", "bell1", "bell2", "glass", "metal", "mug", "harmonic", "hihat", "woodblock"
  };
  return QString(ringFileArray[static_cast<int>(rt)]);
}


QString TaudioOUT::getRingName(int rt) {
  if (rt < 0 || rt > ringTypeCount() - 1)
    return QString();
  static const char* const ringNameArr[static_cast<int>(Ring_TypesCount)] = {
    QT_TRANSLATE_NOOP("RingType", "None"), QT_TRANSLATE_NOOP("RingType", "Bell"),
    QT_TRANSLATE_NOOP("RingType", "Other bell"), QT_TRANSLATE_NOOP("RingType", "Yet another bell"),
    QT_TRANSLATE_NOOP("RingType", "Glass"), QT_TRANSLATE_NOOP("RingType", "Metal sheet"),
    QT_TRANSLATE_NOOP("RingType", "Spoon at mug"), QT_TRANSLATE_NOOP("RingType", "Guitar harmonic"),
    QT_TRANSLATE_NOOP("RingType", "Hi hat"), QT_TRANSLATE_NOOP("RingType", "Woodblock")
  };
  return QGuiApplication::translate("RingType", ringNameArr[rt]);
}


void TaudioOUT::setMeter(int m) {
  if (m_meter != m) {
    m_meter = m;
    emit meterChanged();
    setMeterCount(0);
  }
}


void TaudioOUT::setMeterCount(int mc) {
  if (m_meterCount != mc) {
    m_meterCount = mc;
    emit meterCountChanged();
  }
}


void TaudioOUT::setRing(bool r) {
  if (r != m_doRing) {
    m_doRing = r;
    emit ringChanged();
  }
}


void TaudioOUT::setTempo(int t) {
  if (t != m_tempo && t > 39 && t < 241) {
    m_tempo = t;
    m_samplPerBeat = (48000 * 60) / t;
    m_offsetSample = static_cast<qreal>((60 * 48000) - m_samplPerBeat * t) / static_cast<qreal>(t);
    m_offsetCounter = 0.0;
    m_missingSampleNr = 0;
    emit tempoChanged();
    setNameIdByTempo(m_tempo);
  }
}


QString TaudioOUT::getTempoNameById(int nameId) {
  return nameId < GLOB->temposCount() ? GLOB->tempoName(nameId).name() : QString();
}


//#################################################################################################
//###################                PROTECTED         ############################################
//#################################################################################################
QString TaudioOUT::getRawFilePath(const QString& fName) {
#if defined (Q_OS_ANDROID)
  QString beatFileName = QStringLiteral("assets:/Sounds/");
#elif defined (Q_OS_WIN)
    QString beatFileName = qApp->applicationDirPath() + QLatin1String("/Sounds/");
#else
  QString beatFileName = qApp->applicationDirPath() + QLatin1String("/../share/metronomek/Sounds/");
#endif
  return beatFileName + fName +  QLatin1String(".raw48-16");
}


void TaudioOUT::setNameTempoId(int ntId) {
  if (ntId != m_nameTempoId) {
    m_nameTempoId = ntId;
    emit nameTempoIdChanged();
  }
}


void TaudioOUT::setNameIdByTempo(int t) {
  for (int i = 0; i < GLOB->temposCount(); ++i) {
    if (t < GLOB->tempoName(i).hi()) {
      setNameTempoId(i);
      return;
    }
  }
}
