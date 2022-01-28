/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TCOUNTINGMANAGER_H
#define TCOUNTINGMANAGER_H


#include <QtCore/qobject.h>


class TsoundData;
class TabstractAudioDevice;


/**
 * 
 */
class TcountingManager : public QObject
{

  Q_OBJECT

public:
  explicit TcountingManager(QVector<TsoundData*>* numList, QObject* parent = nullptr);
  ~TcountingManager() override;

      /**
       * @p TRUE when import was done
       */
  bool finished() const { return m_finished; }
//   void setFinished(bool finished);

  void importFormFile(const QString& fileName, int noiseThreshold = 400);

  void importFromCommandline();

#if defined (Q_OS_ANDROID)
  void importFromTTS();
#endif

//   void importFromResources();

  void initSettings(TabstractAudioDevice* audioDev);
  void restoreSettings();

  Q_INVOKABLE void play(int numer);
  Q_INVOKABLE void rec(int numer);

signals:
  void finishedChanged();
  void recFinished(int nr, bool tooLong);

protected:
#if defined (WITH_SOUNDTOUCH)
      /**
       * Changes length of @p in counting data to appropriate duration: 300ms.
       * Saves new stream into @p out with duration @p outLen frames
       */
  void squash(qint16* in, quint32 inLen, qint16*& out, quint32& outLen);
#endif

  void playCallBack(char* data, unsigned int maxLen, unsigned int& wasRead);
  void recCallBack(char* data, unsigned int maxLen, unsigned int& wasRead);

      /**
       * When playing (m_playing == true) starts timer every 20 ms
       * to check is it stopped (m_playing == false) - playCallBack sets that.
       * When finished - stops audio device.
       * It avoids high CPU usage under PulseAudio
       * and doesn't harm under other audio back-ends.
       */
  void watchPlayingStopped();

  void watchRecordingStopped();

private:
  bool                              m_finished = false;
  QVector<TsoundData*>             *m_numerals = nullptr;
  bool                              m_doSquash = false;
  bool                              m_alignCounting = true;
  TabstractAudioDevice             *m_audioDevice = nullptr;
  int                               m_currSample = 0;
  int                               m_playNum = 0, m_recNum = 0;
  bool                              m_playing = false, m_recording = false;
  qint16                           *m_inBuffer = nullptr;
  quint32                           m_inSize = 0, m_inPos = 0, m_endPos = 0;
  qint16                            m_inNoise = 0, m_inMax = 0;
  bool                              m_inOnSet = false;
};

#endif // TCOUNTINGMANAGER_H