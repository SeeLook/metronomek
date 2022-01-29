/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "tcountingmanager.h"
#include "tsounddata.h"
#include "tabstractaudiodevice.h"
#include "tnumeralspectrum.h"

#if defined (WITH_SOUNDTOUCH)
  #include <soundtouch/SoundTouch.h>
#endif

#include <QtCore/qcommandlineparser.h>
#include <QtCore/qfile.h>
#include <QtCore/qdir.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qendian.h>
#include <QtCore/qtimer.h>
#include <QtGui/qguiapplication.h>

#include <QtCore/qdebug.h>


class Tmark
{
  public:
    Tmark(quint32 f, quint32 t) : m_from(f), m_to(t) {}
    Tmark(int f, int t) : m_from(f), m_to(t) {}

    quint32 from() const { return m_from; }

    quint32 to() const { return m_to; }

    quint32 length() const { return m_to - m_from; }

  private:
    quint32       m_from = 0;
    quint32       m_to = 0;
};


TcountingManager::TcountingManager(QVector<TsoundData*>* numList, QObject* parent) :
  QObject(parent),
  m_numerals(numList)
{
}


TcountingManager::~TcountingManager()
{
  if (m_inBuffer)
    delete[] m_inBuffer;
}


void TcountingManager::importFromCommandline() {
  int noiseThreshold = 400;
  QCommandLineParser cmd;
  QCommandLineOption noiseThresholdOpt(QStringList() << QStringLiteral("noise-threshold") << QStringLiteral("t"),
                              QStringLiteral("\n"),
                              QStringLiteral("%"));
  cmd.addOption(noiseThresholdOpt);

  QCommandLineOption alignCntOpt(QStringList() << QStringLiteral("no-align") << QStringLiteral("a"),
                                 QStringLiteral("\n"),
                                 QString());
  cmd.addOption(alignCntOpt);

#if defined (WITH_SOUNDTOUCH)
  QCommandLineOption shrinkOpt(QStringList() << QStringLiteral("shrink-counting") << QStringLiteral("s"),
                               QStringLiteral("\n"),
                               QStringLiteral("false"));
  cmd.addOption(shrinkOpt);
#endif

  cmd.parse(qApp->arguments());
  if (cmd.isSet(noiseThresholdOpt))
    noiseThreshold = qRound((cmd.value(noiseThresholdOpt).toDouble() * 32768.0) / 100.0);
  if (cmd.isSet(alignCntOpt))
    m_alignCounting = false;

#if defined (WITH_SOUNDTOUCH)
  m_doSquash = cmd.isSet(shrinkOpt);
#endif

  importFormFile(qApp->arguments().last(), noiseThreshold);
}


void TcountingManager::importFormFile(const QString& fileName, int noiseThreshold) {
  qDebug() << "[TcountingManager] Importing from" << fileName << "threshold" << noiseThreshold;

  const QUrl url(fileName);
  auto fn = url.isLocalFile() ? QDir::toNativeSeparators(url.toLocalFile()) : fileName;

  QFile audioF(fn);
  if (!audioF.exists()) {
    qDebug() << "[TcountingManager] File doesn't exist!" << fn;
    return;
  }

  quint32          sampleRate = 48000;
  int              frames;
  qint16*          data = nullptr;
  bool             ok = true;

// Read audio data from file into data array
  if (audioF.open(QIODevice::ReadOnly)) {
      QDataStream      in;
      quint16          channelsNr = 1;

      auto ext = fileName.right(3).toLower();
      if (ext == QLatin1String("wav")) {
          in.setDevice(&audioF);
          qint32 headChunk;
          in >> headChunk;
          headChunk = qFromBigEndian<qint32>(headChunk);

          quint32 chunkSize;
          in >> chunkSize;
          chunkSize = qFromBigEndian<quint32>(chunkSize);
          in >> headChunk;
          headChunk = qFromBigEndian<qint32>(headChunk);

          if (headChunk == 1163280727) { // 1163280727 is 'value' of 'WAVE' text in valid WAV file
              in >> headChunk;
              headChunk = qFromBigEndian<qint32>(headChunk);

              in >> chunkSize;
              quint16 audioFormat;
              in >> audioFormat;
              audioFormat = qFromBigEndian<quint16>(audioFormat);
              // TODO: interpret audioFormat == 0 - another header
              if (headChunk == 544501094 && audioFormat == 1) { // 544501094 is 'value' of 'fmt ' text in valid WAV file
                  in >> channelsNr;
                  channelsNr = qFromBigEndian<quint16>(channelsNr);
                  in >> sampleRate;
                  sampleRate = qFromBigEndian<quint32>(sampleRate);
                  quint32 byteRate;
                  in >> byteRate;
                  byteRate = qFromBigEndian<quint32>(byteRate);
                  quint16 blockAlign;
                  in >> blockAlign;
                  blockAlign = qFromBigEndian<quint16>(blockAlign);
                  quint16 bitsPerSample;
                  in >> bitsPerSample;
                  bitsPerSample = qFromBigEndian<quint16>(bitsPerSample);
                  if (bitsPerSample != 16) {
                    qDebug() << "[TcountingManager] Only *.wav with 16 bit per sample are supported.";
                    ok = false;
                  }
                  in >> headChunk;
                  headChunk = qFromBigEndian<qint32>(headChunk);

                  quint32 audioDataSize;
                  in >> audioDataSize;
                  audioDataSize = qFromBigEndian<quint32>(audioDataSize);

                  frames = audioDataSize / (channelsNr * 2);
                  data = new qint16[audioDataSize / 2];
                  qint16 channelSample;
                  for (int f = 0; f < frames; ++f) {
                    in >> channelSample;
                    if (channelsNr == 2) // prefer right channel when stereo
                      in >> channelSample;
                    data[f] = qFromBigEndian<qint16>(channelSample);
                  }
                  frames = audioDataSize / 2;
              } else {
                  qDebug() << "[TcountingManager] Unsupported audio format in file:" << fileName;
                  ok = false;
              }
          } else {
              qDebug() << "[TcountingManager] "<< fileName << "is not valid *,wav file";
              ok = false;
          }
      } else if (ext == QLatin1String("raw")) {
          frames = static_cast<int>(audioF.size() / 2);
          data = new qint16[frames];
          QDataStream stream(&audioF);
          stream.readRawData(reinterpret_cast<char*>(data), frames * 2);
      }
  } else {
      ok = false;
      qDebug() << "[TcountingManager] Cannot open file" << fileName;
  }

  if (!data || !ok) {
    qDebug() << "[TcountingManager] Something went wrong in" << fn << data << ok;
    if (data)
      delete[] data;
    return;
  }

// determine noise level
  qint16 noiseLevel = 10;
  for (int f = 0; f < 48000; ++f) {
    noiseLevel = qMax(noiseLevel, qAbs(data[f]));
  }
  qDebug() << "Noise level is" << noiseLevel;

// find numerals data and mark them: point.x = start, point.y = end
  qint16 max = 0;
  bool onSetFound = false;
  int onSetAt = 0;
  int onEndAt = 0;
  int silCnt = 0;
  QVector<Tmark> numerals;

  for (int f = 48001; f < frames; ++f) {
    qint16 absData = qAbs(data[f]);
    if (onSetFound) {
        if (max && ((data[f] >= 0 && data[f - 1] <= 0))) {
          if (max > noiseLevel) {
              silCnt = 0;
          } else {
              if (f - onSetAt > 9000) { // 187.5 ms at least
                silCnt++;
                if (silCnt > 30) {
                    onSetFound = false;
                    onEndAt = f;
                    silCnt = 0;
                    numerals << Tmark(onSetAt, onEndAt);
                    qDebug() << "finished" << onEndAt << (onEndAt / 48000.0) << "dur:" << (onEndAt - onSetAt) << ((onEndAt - onSetAt) / 48000.0);
                }
              } else if (f - onSetAt > 2000) { // 55 ms
                  silCnt++;
                  if (silCnt > 30) {
                    onSetFound = false;
                    silCnt = 0;
                  }
              }
          }
          max = 0;
        }
        max = qMax(max, absData);
    } else {
        if (absData > noiseThreshold) {
          onSetFound = true;
          int pos = f - 1;
          while ((data[pos] >= 0 && data[pos - 1] >= 0) || (data[pos] < 0 && data[pos - 1] < 0))
            pos--;
          onSetAt = pos;
          qDebug() << numerals.count() + 1 << "\non set at" << pos << (pos / 48000.0);
          max = 0;
        }
    }
  }

// copy numerals samples into TaudioOut
  if (!numerals.isEmpty()) {
    qDebug() << "Found" << numerals.size();

    bool doCreate = m_numerals->isEmpty();

    int maxTopPos = 0;
    for (int d = 0; d < 12; ++d) {
      if (d < numerals.size()) {
        Tmark* marks = &numerals[d];
#if defined (WITH_SOUNDTOUCH)
        bool doSquash = m_doSquash && marks->length() > 17500;
#else
        bool doSquash = false;
#endif
        quint32 len = doSquash ? 0 : marks->length();
        qint16* squashData = doSquash ? nullptr : data + marks->from();
#if defined (WITH_SOUNDTOUCH)
        if (doSquash) {
          squash(data + marks->from(), marks->length(), squashData, len);
        }
#endif
        if (doCreate)
          m_numerals->append(new TsoundData(squashData, len));
        else
          m_numerals->at(d)->copyData(squashData, len);
        if (doSquash)
          delete[] squashData;
        maxTopPos = qMax(maxTopPos, m_numerals->at(d)->findPeakPos());
      }
    }
    if (m_alignCounting) {
      for (int d = 0; d < qMin(numerals.size(), 12); ++d) {
        m_numerals->at(d)->setOffset(maxTopPos - m_numerals->at(d)->peakAt());
      }
      for (int d = 0; d < qMin(numerals.size(), 12); ++d) {
        if (d < m_spectrums.count())
          m_spectrums[d]->setNumeral(m_numerals->at(d));
      }
    }
  }

  delete[] data;
}


#if defined (Q_OS_ANDROID)
void TcountingManager::importFromTTS() {

}
#endif


void TcountingManager::initSettings(TabstractAudioDevice* audioDev) {
  m_audioDevice = audioDev;
  connect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &TcountingManager::playCallBack, Qt::DirectConnection);
}


void TcountingManager::restoreSettings() {
  if (m_audioDevice->audioMode() == TabstractAudioDevice::Audio_Output)
    disconnect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &TcountingManager::playCallBack);
  else
    disconnect(m_audioDevice, &TabstractAudioDevice::takeAudio, this, &TcountingManager::recCallBack);
  m_spectrums.clear();
}


void TcountingManager::addSpectrum(TnumeralSpectrum* spectItem) {
  if (spectItem->nr() == m_spectrums.count())
    m_spectrums << spectItem;
  else if (spectItem->nr() < m_spectrums.count())
    m_spectrums[spectItem->nr()] = spectItem;

  spectItem->setNumeral(m_numerals->at(spectItem->nr()));
}


void TcountingManager::play(int numer) {
  if (m_spectrums[numer]->numeral() == nullptr)
    return;

  m_playNum = numer;
  m_currSample = 0;
  if (m_audioDevice->audioMode() != TabstractAudioDevice::Audio_Output) {
    disconnect(m_audioDevice, &TabstractAudioDevice::takeAudio, this, &TcountingManager::recCallBack);
    connect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &TcountingManager::playCallBack, Qt::DirectConnection);
  }
  m_audioDevice->startPlaying();
  m_playing = true;
  watchPlayingStopped();
}


void TcountingManager::rec(int numer) {
  if (m_audioDevice->audioMode() != TabstractAudioDevice::Audio_Input) {
    disconnect(m_audioDevice, &TabstractAudioDevice::feedAudio, this, &TcountingManager::playCallBack);
    connect(m_audioDevice, &TabstractAudioDevice::takeAudio, this, &TcountingManager::recCallBack, Qt::DirectConnection);
  }
  if (!m_inBuffer)
    m_inBuffer = new qint16[48000]; // 1 sec. buffer is enough
  m_spectrums[numer]->startRecording();
  m_recNum = numer;
  m_inSize = 0;
  m_inPos = 0;
  m_endPos = 0;
  m_inNoise = 400;
  m_inOnSet = false;
  m_recording = true;
  m_audioDevice->startRecording();
  watchRecordingStopped();
}


// void TcountingManager::setFinished(bool finished)
// {
//   if (m_finished != finished) {
//     m_finished = finished;
//     emit finishedChanged();
//   }
// }

//#################################################################################################
//###################                PROTECTED         ############################################
//#################################################################################################

#if defined (WITH_SOUNDTOUCH)
void TcountingManager::squash(qint16* in, quint32 inLen, qint16*& out, quint32& outLen) {
  auto sTouch = new soundtouch::SoundTouch();
  sTouch->setChannels(1);
  sTouch->setSampleRate(48000);
  sTouch->setTempo(static_cast<qreal>(inLen) / 16800.0);
  auto floatIn = new float[inLen];
  for (int s = 0; s < inLen; ++s)
    floatIn[s] = in[s] / 32768.0f;

  auto outTouch = new float[inLen];
  sTouch->putSamples(static_cast<soundtouch::SAMPLETYPE*>(floatIn), inLen);
  uint samplesReady = 0;
  outLen = 0;
  do {
      samplesReady = sTouch->receiveSamples(static_cast<soundtouch::SAMPLETYPE*>(outTouch), inLen);
      outLen += samplesReady;
  } while (samplesReady != 0);

  qDebug() << "squash" << static_cast<qreal>(inLen) / 16800.0 << inLen << outLen;
  out = new qint16[outLen];
  for (int s = 0; s < outLen; ++s)
    out[s] = static_cast<qint16>(outTouch[s] * 32768);

  delete[] outTouch;
  delete[] floatIn;
  delete sTouch;
}
#endif

#define CALLBACK_CONTINUE (0)
#define CALLBACK_STOP (2)

void TcountingManager::playCallBack(char* data, unsigned int maxLen, unsigned int& wasRead) {
  qint16 sample = 0;
  auto out = reinterpret_cast<qint16*>(data);
  auto num = m_spectrums[m_playNum]->numeral();

  for (unsigned int i = 0; i < maxLen; i++) {
    sample = num->sampleAt(m_currSample);
    *out++ = sample; // left channel
    *out++ = sample; // right channel
    m_currSample++;
  }
  if (m_currSample < 36000) {
      wasRead = CALLBACK_CONTINUE;
  } else {
      wasRead = CALLBACK_STOP;
      m_playing = false;;
  }
}


void TcountingManager::recCallBack(char* data, unsigned int maxLen, unsigned int& wasRead) {
  wasRead = m_recording ? CALLBACK_CONTINUE : CALLBACK_STOP;
  if (!m_recording)
    return;

  auto in = reinterpret_cast<qint16*>(data);
  qint16 sample = 0;
  for (uint i = 0; i < maxLen; ++i) {
    sample = in[i];
    qint16 absData = qAbs(sample);
    if (m_inPos < 24000) {
        m_inNoise = qMax(m_inNoise, absData);
    } else if (!m_inOnSet) {
        if (absData > m_inNoise) {
          m_inOnSet = true;
          quint32 pos = i - 1;
          // find 0-cross
          while (pos > -1 && ((in[pos] >= 0 && in[pos - 1] >= 0) || (in[pos] < 0 && in[pos - 1] < 0)))
            pos--;
          // copy data from 0-cross position to current i
          for (uint p = pos; p <= i; ++p)
            m_inBuffer[p] = in[p];
          m_inSize = i - pos + 1;
          m_inMax = 0;
        }
    } else if (m_inOnSet) {
        if (m_inSize < 48000) {
            m_inBuffer[m_inSize] = in[i];
            m_inSize++;
        } else { // to long
            wasRead = CALLBACK_STOP;
            m_recording = false;
            break;
        }
        qint16 prevSample = i == 0 ? m_inBuffer[m_inSize - 1] : in[i - 1];
        if ((in[i] >= 0 && prevSample <= 0)) {
            if (m_inMax < m_inNoise * 1.5) {
                if (m_endPos) {
                    if (m_inPos - m_endPos > 2400) { // saying numeral finished
                      m_inSize = m_inSize - (m_inPos - m_endPos);
                      wasRead = CALLBACK_STOP;
                      m_recording = false;
                      break;
                    }
                } else {
                    m_endPos = m_inPos;
                }
            } else {
                m_endPos = 0;
            }
            m_inMax = 0;
        } else {
            m_inMax = qMax(m_inMax, absData);
        }
    }
    m_inPos++;
  }
}


void TcountingManager::watchPlayingStopped() {
  if (m_playing)
    QTimer::singleShot(20, this, [=]{ watchPlayingStopped(); });
  else
    m_audioDevice->stop();
}


void TcountingManager::watchRecordingStopped() {
  if (m_recording)
      QTimer::singleShot(20, this, [=]{ watchRecordingStopped(); });
  else {
      m_audioDevice->stop();
      auto spectrum = m_spectrums[m_recNum];
      spectrum->copyData(m_inBuffer, m_inSize);
//       m_numerals->at(m_recNum)->copyData(m_inBuffer, m_inSize);
  }
}
