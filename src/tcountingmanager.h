/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TCOUNTINGMANAGER_H
#define TCOUNTINGMANAGER_H


#include <QtCore/qobject.h>


class TsoundData;
class TabstractAudioDevice;
class TnumeralSpectrum;
class TcntXML;
class QDataStream;
class QFile;


/**
 * 
 */
class TcountingManager : public QObject
{

  Q_OBJECT

  Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged)
  Q_PROPERTY(int localModelId READ localModelId WRITE setLocalModelId NOTIFY localModelIdChanged)

public:
  explicit TcountingManager(QObject* parent = nullptr);
  ~TcountingManager() override;

  QVector<TsoundData*>* numerals() { return &m_numerals; }

//===================================================
// Methods for importing counting
//===================================================
  Q_INVOKABLE void importFormFile(const QString& fileName, int noiseThreshold = 400);

  void importFromCommandline();

#if defined (Q_OS_ANDROID)
  void importFromTTS();
#endif

//===================================================
// Methods for custom counting preparation/recording
//===================================================
  void initSettings(TabstractAudioDevice* audioDev);
  void restoreSettings();

      /**
       * It sets numeral audio data to given @p TnumeralSpectrum.
       * This way the data doesn't vanish when @p NumeralSpectrum is deleted
       * - it is delegate of QML ListView
       * QML VerbalCountPage has to register every NumeralSpectrum item
       * by calling this method.
       */
  Q_INVOKABLE void addSpectrum(TnumeralSpectrum* spectItem);

  Q_INVOKABLE void play(int numer);
  Q_INVOKABLE void rec(int numer);

      /**
       * Checks read permission under Android
       * On desktop always returns @p TRUE
       */
  Q_INVOKABLE bool checkReadPermission();

      /**
       * On desktop invokes file dialog to get sound (wav, raw) file.
       * Does nothing under Android
       */
  Q_INVOKABLE void getSoundFile();

  Q_INVOKABLE void storeCounting(int lang, const QString& name, bool askForFile = false);

  Q_INVOKABLE QStringList languagesModel();
  Q_INVOKABLE int currentLanguage();

  Q_INVOKABLE void getSingleWordFromFile(int numId);

//===================================================
// Methods to handle locally stored *.wav files with counting
//===================================================

  int localModelId() const { return m_localModelId; }
  void setLocalModelId(int mId);

  Q_INVOKABLE QStringList countingModelLocal();

  QStringList lookupForWavs(const QString& wavDir, QStringList* wavFilesList = nullptr);
  QString getModelEntryFromXml(const QString& xmlString);

  Q_INVOKABLE void removeLocalWav(int cntId);

//===================================================
// Methods for downloading a file
//===================================================

  bool downloading() const { return m_downloading; }

  Q_INVOKABLE QStringList onlineModel();

  Q_INVOKABLE void downloadCounting(int urlId);

      /**
       * Parses @p mdFile
       * Creates @p QStringList model from given @p mdFilePath
       * by parsing MarkDown table with counting files
       */
  QStringList convertMDtoModel(const QString& mdFileName);

//===================================================
// *.wav and iXML manipulating helpers
//===================================================

      /**
       * Write to *.wav format, as simple as possible.
       * Only 16 bytes 'fmt ' chunk, then counting data chunk
       * and at the end extra 'iXML' chunk with information
       * where every numeral sound data starts.
       */
  bool writeWavFile(const QString& cntFileName, const TcntXML& xml);

  QString dumpXmlFromWav(const QString& fileName);

      /**
       * Returns @p QString with XML data from given
       * @p QDataStream which should be wav file context.
       */
  QString dumpXmlFromDataStream(QDataStream& in);

      /**
       * Parses @p audioFile which has to be *.wav or *.raw format (16/48000),
       * for uncompressed PCM data
       * which is then written into @p data of @p frames number
       * and if given wav file contains iXML, to @p xml class reference.
       * NOTICE: The caller method is responsible for data deletion!
       */
  void getDataFromAudioFile(QFile* audioFile, qint16*& data, int& frames, TcntXML& xml);

      /**
       * Looks up into @p data of @p frames number
       * and writes detected saying of numeral into @p numList.
       * Numeral begins when PCM data is above @p noiseThreshold
       */
  void detectNumerals(qint16* data, int frames, QVector<TsoundData*>& numList, int noiseThreshold = 400);


signals:
  void downloadingChanged();
  void downProgress(qreal progress);
  void abortDownload();
  void localModelIdChanged();

      /**
       * Emitted when wav file download was completed with success.
       * @p modelEntry is for QML to consume
       */
  void appendToLocalModel(const QString& modelEntry);

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

  QString getWavFileName(const QString& langPrefix);

  QString soundFileDialog();

private:
  QVector<TsoundData*>              m_numerals;
// importing
  bool                              m_doSquash = false;
  bool                              m_alignCounting = true;
// preparation of counting
  QVector<TnumeralSpectrum*>        m_spectrums;
  TabstractAudioDevice             *m_audioDevice = nullptr;
  int                               m_currSample = 0;
  int                               m_playNum = 0, m_recNum = 0;
  bool                              m_playing = false, m_recording = false;
  qint16                           *m_inBuffer = nullptr;
  quint32                           m_inSize = 0, m_inPos = 0, m_endPos = 0;
  qint16                            m_inNoise = 0, m_inMax = 0;
  bool                              m_inOnSet = false;
  QStringList                       m_languagesModel;
// local counting wav files
  int                               m_localModelId = 0;
  QStringList                       m_localCntModel;
  QStringList                       m_localWavFiles;
  QString                           m_prevLocalWav, m_defaultWav;
// downloading wav-es
  QStringList                       m_onlineModel;
  QStringList                       m_onlineURLs;
  bool                              m_downloading = false;
};

#endif // TCOUNTINGMANAGER_H
