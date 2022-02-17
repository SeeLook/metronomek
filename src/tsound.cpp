/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "tsound.h"
#if defined (Q_OS_ANDROID)
//  #include "tqtaudioout.h"
  #include "toboedevice.h"
#else
  #include "trtaudiodevice.h"
#endif
// #include "taudiobuffer.h"
#include "ttempopart.h"
#include "tspeedhandler.h"
#include "tcountingmanager.h"
#include "tnumeralspectrum.h"
#include "tglob.h"

#include <QtQml/qqml.h>
#include <QtGui/qguiapplication.h>
#include <QtCore/qtimer.h>
#include <QtCore/qfile.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qsettings.h>
#include <QtCore/qmath.h>

#include <QtCore/qdebug.h>


//#################################################################################################
//###################                Tsound         ############################################
//#################################################################################################

/*static*/
QStringList Tsound::getAudioDevicesList() {
#if defined (Q_OS_ANDROID)
  return QStringList();
//  return TqtAudioOut::getAudioDevicesList();
#else
  return TRtAudioDevice::getAudioOutDevicesList();
#endif
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


Tsound*             Tsound::m_instance = nullptr;
/*end static*/



Tsound::Tsound(QObject *parent) :
  QObject(parent),
  p_ratioOfRate(1),
  m_sampleRate(48000),
  m_callBackIsBussy(false)
{
  if (m_instance) {
    qDebug() << "Nothing of this kind... Tsound already exist!";
    return;
  }
  m_instance = this;

  qmlRegisterUncreatableType<TtempoPart>("Metronomek", 1, 0, "TempoPart", QStringLiteral("Creating TempoPart in QML not allowed!"));
  qmlRegisterUncreatableType<TspeedHandler>("Metronomek", 1, 0, "SpeedHandler", QStringLiteral("Creating SpeedHandler in QML not allowed!"));
  qmlRegisterUncreatableType<TrtmComposition>("Metronomek", 1, 0, "Composition", QStringLiteral("Creating Composition in QML not allowed!"));
  qmlRegisterUncreatableType<TcountingManager>("Metronomek", 1, 0, "CountManager", QStringLiteral("Creating CountManager in QML not allowed!"));
  qmlRegisterType<TnumeralSpectrum>("Metronomek", 1, 0, "NumeralSpectrum");

  setTempo(qBound(40, GLOB->settings()->value(QStringLiteral("tempo"), 60).toInt(), 240));
  m_staticTempo = m_tempo;
  setBeatType(qBound(0, GLOB->settings()->value(QStringLiteral("beatType"), 0).toInt(), beatTypeCount() - 1));
  setMeter(qBound(0, GLOB->settings()->value(QStringLiteral("meter"), 4).toInt(), 12));
  setRingType(qBound(0, GLOB->settings()->value(QStringLiteral("ringType"), 0).toInt(), ringTypeCount() - 1));
  setRing(GLOB->settings()->value(QStringLiteral("doRing"), false).toBool());
  setVariableTempo(GLOB->settings()->value(QStringLiteral("variableTempo"), false).toBool());
  setVerbalCount(GLOB->settings()->value(QStringLiteral("verbalCount"), false).toBool());

  connect(this, &Tsound::finishSignal, this, &Tsound::playingFinishedSlot);

  QTimer::singleShot(500, this, [=]{ init(); });
}


Tsound::~Tsound()
{
  stopTicking();
  m_instance = nullptr;

  if (m_audioDevice && m_audioDevice->deviceName() != QLatin1String("anything"))
    GLOB->settings()->setValue(QStringLiteral("outDevice"), m_audioDevice->deviceName());
  GLOB->settings()->setValue(QStringLiteral("beatType"), m_beatType);
  GLOB->settings()->setValue(QStringLiteral("meter"), m_meter);
  GLOB->settings()->setValue(QStringLiteral("doRing"), m_doRing);
  GLOB->settings()->setValue(QStringLiteral("tempo"), m_variableTempo ? m_staticTempo : m_tempo);
  GLOB->settings()->setValue(QStringLiteral("ringType"), m_ringType);
  GLOB->settings()->setValue(QStringLiteral("variableTempo"), m_variableTempo);
  GLOB->settings()->setValue(QStringLiteral("verbalCount"), m_verbalCount);
}


QString Tsound::outputName() {
  return m_instance && m_instance->m_audioDevice ? m_instance->m_audioDevice->deviceName() : QString();
}


void Tsound::init() {
  if (m_initialized) {
      qDebug() << "[Tsound] has been initialized already! Skipping.";
      return;
  } else {
    #if defined (Q_OS_ANDROID)
//      m_audioDevice = new TqtAudioOut(this);
      m_audioDevice = new TOboeDevice(this);
    #else
      m_audioDevice = new TRtAudioDevice(this);
    #endif
      connect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &Tsound::outCallBack, Qt::DirectConnection);
      auto dn = GLOB->settings()->value(QStringLiteral("outDevice"), QStringLiteral("default")).toString();
      if (dn != QLatin1String("anything")) { // This is workaround for old device name handling
          setDeviceName(GLOB->settings()->value(QStringLiteral("outDevice"), QStringLiteral("default")).toString());
          changeSampleRate(m_audioDevice->sampleRate());
      } else {
          setAudioOutParams();
      }
      if (m_variableTempo && !m_speedHandler)
        speedHandler();
      m_initialized = true;
  }
}


void Tsound::setDeviceName(const QString& devName) {
  if (m_audioDevice->deviceName() != devName) {
    m_audioDevice->setDeviceName(devName);
  }
}


void Tsound::setAudioOutParams() {
  m_audioDevice->setAudioOutParams();
  if (m_audioDevice)
    changeSampleRate(m_audioDevice->sampleRate());
}


void Tsound::setPlaying(bool pl) {
  if (m_playing != pl) {
    if (pl)
      startTicking();
    else
      stopTicking();
  }
}


void Tsound::startTicking() {
  startPlayingSlot();
}


void Tsound::startPlayingSlot() {
  if (!m_playing && !m_goingToStop) {
    m_playingPart = 0;
    m_playingBeat = 1;
    int t = m_variableTempo && m_speedHandler ? m_speedHandler->getTempoForBeat(m_playingPart, m_playingBeat) : m_tempo;
    m_samplPerBeat = (m_sampleRate * 60) / t;
    m_offsetSample = static_cast<qreal>((60 * m_sampleRate) - m_samplPerBeat * t) / static_cast<qreal>(t);
    setNameIdByTempo(t);

    if (m_verbalCount) {
      for (int n = 0; n < 12; ++n) {
        m_numerals->at(n)->setStarted(n == 0);
        m_numerals->at(n)->resetPos();
      }
    }
    m_currSample = 0;
    m_offsetCounter = 0.0;
    m_missingSampleNr = 0;
    if (m_doRing) {
      m_ring.resetPos();
      m_doBell = true;
    }
    m_audioDevice->startPlaying();
    m_playing = true;
    emit playingChanged();
  }
}

#define CALLBACK_CONTINUE (0)
#define CALLBACK_STOP (2)

/**
 * When @p m_offsetSample is greater than 0 - means length of single beat @p m_samplPerBeat (samples number)
 * is not exactly as tempo so after some (plenty) ticks it will shift in real time.
 * To avoid that @p m_missingSampleNr adds single sample length to @p m_samplPerBeat
 * every whole integer summed with @p m_offsetSample
 */
void Tsound::outCallBack(char* data, unsigned int maxLen, unsigned int& wasRead) {
  qint16 sample = 0;
  auto out = reinterpret_cast<qint16*>(data);

  int verbCount = 0;
  if (m_verbalCount)
    verbCount = qBound(0, (m_playingBeat - 1) % meterOfPart(m_playingPart), 11);

  for (unsigned int i = 0; i < maxLen; i++) {
    if (m_verbalCount) {
        if (m_numerals->at(verbCount)->hasNext())
          sample = m_numerals->at(verbCount)->readSample();
        else
          sample = 0;

        int vCnt = verbCount > 0 ? verbCount - 1 : meterOfPart(m_playingPart) - 1;
        while (m_numerals->at(vCnt)->started() && m_numerals->at(vCnt)->hasNext()) {
          sample = mix(sample, m_numerals->at(vCnt)->readSample());
          if (!m_numerals->at(vCnt)->hasNext())
            m_numerals->at(vCnt)->setStarted(false);
          vCnt--;
          if (vCnt < 0)
            vCnt = meterOfPart(m_playingPart) - 1;
        }
//     sample = mix(m_numerals[verbCount]->sampleAt(m_currSample), qRound(m_beat.sampleAt(m_currSample) * 0.6));
    } else
        sample = m_beat.sampleAt(m_currSample);

    m_currSample++;
    if (m_currSample >= m_samplPerBeat + m_missingSampleNr) {

      if (m_goingToStop) {
        m_goingToStop = false;
        wasRead = CALLBACK_STOP;
        return;
      }

      m_playingBeat++;
      int t = m_variableTempo && m_speedHandler ? m_speedHandler->getTempoForBeat(m_playingPart, m_playingBeat) : m_tempo;
      if (t == 0) {
        m_playingPart++;
        m_playingBeat = 1;
        t = m_variableTempo && m_speedHandler ? m_speedHandler->getTempoForBeat(m_playingPart, m_playingBeat) : m_tempo;
        if (t == 0) {
            wasRead = CALLBACK_STOP;
            return;
        }
      }

      if (m_doRing && (m_playingBeat - 1) % meterOfPart(m_playingPart) == 0) {
        m_ring.resetPos();
        m_doBell = true;
      }

      if (m_toNextPart) {
        m_infiBeats = m_playingBeat;
        m_toNextPart = false;
        m_playingPart++;
        m_playingBeat = 0;
      }

      if (m_verbalCount) {
        verbCount = qBound(0, (m_playingBeat - 1) % meterOfPart(m_playingPart), 11);
        m_numerals->at(verbCount)->resetPos();
        m_numerals->at(verbCount)->setStarted(true);
      }

      m_samplPerBeat = (m_sampleRate * 60) / t;
      m_offsetSample = static_cast<qreal>((60 * m_sampleRate) - m_samplPerBeat * t) / static_cast<qreal>(t);
      m_currSample = 0;
      if (m_offsetSample != 0.0) {
        m_offsetCounter += m_offsetSample;
        if (m_offsetCounter > 1.0) {
            m_missingSampleNr = qFloor(m_offsetCounter);
            m_offsetCounter = m_offsetCounter - static_cast<qreal>(m_missingSampleNr);
        } else {
            m_missingSampleNr = 0;
        }
      }
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
    for (int r = 0; r < p_ratioOfRate; r++) {
      *out++ = sample; // left channel
      *out++ = sample; // right channel
    }
  }
//   wasRead = maxLen; // DEPRECATED This is valid only with Android Qt Audio
  wasRead = CALLBACK_CONTINUE;
}


void Tsound::playingFinishedSlot() {
  if (m_playing) {
    m_playing = false;
    emit playingChanged();
    if (!m_goingToStop) {
      m_goingToStop = true;
      int delay = ((m_samplPerBeat - m_currSample) * 1000) / m_sampleRate + 50;
      QTimer::singleShot(qMax(100, delay), this, [=] {
          m_audioDevice->stop();
          m_goingToStop = false;
      });
    }
  }
}


void Tsound::stopTicking() {
  playingFinishedSlot();
}


void Tsound::setBeatType(int bt) {
  if (bt < 0 || bt > static_cast<int>(Beat_TypesCount) - 1) {
    qDebug() << "[Tsound] Wrong beat type!" << bt << "Restore to classic default.";
    bt = 0;
  }
  if (bt != m_beatType) {
    m_beatType = bt;
    m_beat.setFile(getRawFilePath(QLatin1String("beat-") + getBeatFileName(static_cast<EbeatType>(bt))));
    emit beatTypeChanged();
  }
}


QString Tsound::getBeatFileName(Tsound::EbeatType bt) {
  static const char* const beatFileArray[static_cast<int>(Beat_TypesCount)] = {
    "classic", "classic2", "snap", "parapet", "sticks", "sticks2", "clap", "guitar",
    "drum1", "drum2", "drum3", "basedrum", "snaredrum"
  };
  return QString(beatFileArray[static_cast<int>(bt)]);
}


QString Tsound::getBeatName(int bt) {
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


void Tsound::setRingType(int rt) {
  if (rt < 0 || rt > ringTypeCount() - 1) {
    qDebug() << "[Tsound] Wrong ring type!" << rt << "Set to none.";
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


QString Tsound::getRingFileName(Tsound::EringType rt) {
  static const char* const ringFileArray[static_cast<int>(Ring_TypesCount)] = {
    "", "bell", "bell1", "bell2", "glass", "metal", "mug", "harmonic", "hihat", "woodblock"
  };
  return QString(ringFileArray[static_cast<int>(rt)]);
}


QString Tsound::getRingName(int rt) {
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


void Tsound::setMeter(int m) {
  if (m_meter != m) {
    m_meter = m;
    emit meterChanged();
  }
}


void Tsound::setRing(bool r) {
  if (r != m_doRing) {
    m_doRing = r;
    emit ringChanged();
  }
}


void Tsound::setTempo(int t) {
  if (t != m_tempo && t > 39 && t < 241) {
    m_tempo = t;
    m_samplPerBeat = (m_sampleRate * 60) / t;
    m_offsetSample = static_cast<qreal>((60 * m_sampleRate) - m_samplPerBeat * t) / static_cast<qreal>(t);
    m_offsetCounter = 0.0;
    m_missingSampleNr = 0;
    emit tempoChanged();
    setNameIdByTempo(m_tempo);
  }
}


void Tsound::setVerbalCount(bool vc) {
  if (vc != m_verbalCount) {
    m_verbalCount = vc;
    if (m_verbalCount)
      createCountingManager();
    emit verbalCountChanged();
  }
}


void Tsound::setVariableTempo(bool varTemp) {
  if (varTemp != m_variableTempo) {
    m_variableTempo = varTemp;
    if (m_variableTempo)
      m_staticTempo = m_tempo;
    else
      setTempo(m_staticTempo);
    emit variableTempoChanged();
  }
}


QString Tsound::getTempoNameById(int nameId) {
  return nameId < GLOB->temposCount() ? GLOB->tempoName(nameId).name() : QString();
}


void Tsound::importFromCommandline() {
  createCountingManager();
  m_countManager->importFromCommandline();
}


void Tsound::createCountingManager() {
  if (!m_countManager) {
    m_countManager = new TcountingManager(this);
    m_numerals = m_countManager->numerals();
  }
}



void Tsound::initCountingSettings() {
  createCountingManager();
  disconnect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &Tsound::outCallBack);
  m_countManager->initSettings(m_audioDevice);
}


void Tsound::restoreAfterCountSettings() {
  m_countManager->restoreSettings();
  connect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &Tsound::outCallBack, Qt::DirectConnection);
}


//#################################################################################################
//############                Tempo change methods         ########################################
//#################################################################################################

TspeedHandler* Tsound::speedHandler() {
  if (!m_speedHandler)
    m_speedHandler = new TspeedHandler(this);
  return m_speedHandler;
}


int Tsound::getTempoForBeat(int partId, int beatNr) {
  if (m_variableTempo && m_speedHandler) {
    if (partId < m_speedHandler->currComp()->partsCount() && m_speedHandler->currComp()->getPart(partId)->infinite()
      && m_infiBeats && beatNr >= m_infiBeats)
    {
      m_infiBeats = 0;
      return 0;
    }

    return m_speedHandler->getTempoForBeat(partId, beatNr);
  }

  return m_tempo;
}


bool Tsound::isPartInfinite(int partId) {
  if (m_variableTempo && m_speedHandler && partId < m_speedHandler->currComp()->partsCount() - 1) {
      auto p = m_speedHandler->currComp()->getPart(partId);
      return p ? p->infinite() : false;
  } else
      return false;
}


void Tsound::switchInfinitePart() {
  if (isPartInfinite(m_playingPart))
    m_toNextPart = true;
  else
    qDebug() << "[Tsound] FIXME! Trying to switch non infinite tempo part!";
}


int Tsound::meterOfPart(int partId) {
  if (m_variableTempo && m_speedHandler && partId < m_speedHandler->currComp()->partsCount())
    return m_speedHandler->currComp()->getPart(partId)->meter();
  else
    return m_meter;
}


//#################################################################################################
//###################                PROTECTED         ############################################
//#################################################################################################
QString Tsound::getRawFilePath(const QString& fName) {
  return GLOB->soundsPath() + fName +  QLatin1String(".raw48-16");
}


void Tsound::setNameTempoId(int ntId) {
  if (ntId != m_nameTempoId) {
    m_nameTempoId = ntId;
    emit nameTempoIdChanged();
  }
}


void Tsound::setNameIdByTempo(int t) {
  for (int i = 0; i < GLOB->temposCount(); ++i) {
    if (t <= GLOB->tempoName(i).hi()) {
      setNameTempoId(i);
      return;
    }
  }
}


void Tsound::changeSampleRate(quint32 sr) {
  if (sr != m_sampleRate) {
    m_sampleRate = sr;
    // Also refresh tempo related variables - force tempo change routines
    //TODO: when sample rate is greater than 48000, set p_ratioOfRate according to it
    m_tempo++;
    setTempo(m_tempo - 1);
  }
}
