/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TAUDIOOUT_H
#define TAUDIOOUT_H


#include <QtCore/qobject.h>


class TabstractAudioOutput;
class TspeedHandler;


#define SOUND (TaudioOUT::instance())


/**
 * Buffer-like structure to keep and handle audio data
 */
class TsoundData {

public:
  TsoundData() {}
  TsoundData(const QString& rawFileName);
  ~TsoundData();

  int size() const { return m_size; }

      /**
       * sample value or null if out of scope
       */
  qint16 sampleAt(int samPos) const { return samPos < m_size ? m_data[samPos] : 0; }

      /**
       * Returns sample at current position and moves one step forward.
       * When position is out of scope, returns null
       */
  qint16 readSample() { m_pos++; return sampleAt(m_pos - 1); }

  int pos() const { return m_pos; }

      /**
       * Resets position
       */
  void resetPos() { m_pos = 0; }

  qint16* data() { return m_data; }

      /**
       * Reads audio data from raw audio file with given name
       */
  void setFile(const QString& rawFileName);

  void deleteData();

private:
  qint16             *m_data = nullptr;
  int                 m_pos = 0;
  int                 m_size = 0;
};


/**
 * Class that manages selected beat samples to Qt audio output
 */
class TaudioOUT : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool playing READ playing WRITE setPlaying NOTIFY playingChanged)
  Q_PROPERTY(int beatType READ beatType WRITE setBeatType NOTIFY beatTypeChanged)
  Q_PROPERTY(int meter READ meter WRITE setMeter NOTIFY meterChanged)
  Q_PROPERTY(int ringType READ ringType WRITE setRingType NOTIFY ringTypeChanged)
  Q_PROPERTY(bool ring READ ring WRITE setRing NOTIFY ringChanged)
  Q_PROPERTY(int tempo READ tempo WRITE setTempo NOTIFY tempoChanged)
  Q_PROPERTY(int nameTempoId READ nameTempoId NOTIFY nameTempoIdChanged)
  // tempo change properties
  Q_PROPERTY(bool variableTempo READ variableTempo WRITE setVariableTempo NOTIFY variableTempoChanged)

public:
  TaudioOUT(QObject* parent = nullptr);
  ~TaudioOUT() override;

  static TaudioOUT* instance() { return m_instance; }

  void init();

  Q_INVOKABLE static QStringList getAudioDevicesList();
  Q_INVOKABLE static QString outputName();

  Q_INVOKABLE void startTicking();
  Q_INVOKABLE void stopTicking();

  Q_INVOKABLE void setDeviceName(const QString& devName);

  void setAudioOutParams();

  bool playing() const { return m_playing; }
  void setPlaying(bool pl);

  enum EbeatType {
    Beat_Classic, Beat_Classic2,
    Beat_Snap, Beat_Parapet,
    Beat_Sticks, Beat_Sticks2,
    Beat_Clap, Beat_Guitar,
    Beat_Drum1, Beat_Drum2, Beat_Drum3,
    Beat_BaseDrum, Beat_SnareDrum,
    Beat_TypesCount
  };
  Q_ENUM(EbeatType)

  Q_INVOKABLE int beatTypeCount() const { return static_cast<int>(Beat_TypesCount); }
  int beatType() const { return m_beatType; }
  void setBeatType(int bt);
  QString getBeatFileName(EbeatType bt);
  Q_INVOKABLE QString getBeatName(int bt);

  enum EringType {
    Ring_None, Ring_Bell, Ring_Bell2, Ring_Bell3, Ring_Glass, Ring_Metal, Ring_Mug, Ring_Harmonic,
    Ring_HiHat, Ring_WoodBlock,
    Ring_TypesCount
  };
  Q_ENUM(EringType)

  Q_INVOKABLE int ringTypeCount() const { return static_cast<int>(Ring_TypesCount); }
  int ringType() const { return m_ringType; }
  void setRingType(int rt);
  QString getRingFileName(EringType rt);
  Q_INVOKABLE QString getRingName(int rt);

  int meter() const { return m_meter; }
  void setMeter(int m);

  bool ring() const { return m_doRing; }
  void setRing(bool r);

  int tempo() const { return m_tempo; }
  void setTempo(int t);

  int nameTempoId() const { return m_nameTempoId; }

  bool variableTempo() const { return m_variableTempo; }
  void setVariableTempo(bool varTemp);

  Q_INVOKABLE QString getTempoNameById(int nameId);

//############  Tempo change methods    ####################

  Q_INVOKABLE TspeedHandler* speedHandler();

      /**
       *
       * Visual ticking animation and playing audio callbacks
       * work totally in parallel and there is only one common factor:
       *                the time.
       *
       * It is easy to keep them in sync for static tempo, but when tempo changes
       * filling audio stream routines are ahead of time loop of pendulum animation
       *
       * @p getTempoForBeat(part ID, beat number)
       * returns tempo value for given number of beat of tempo part.
       * When tempo doesn't change it is always the same value,
       * but when there is accelerando or rallentando values are different.
       * Returns 0 when there is not such a beat number in given part ID.
       */
  Q_INVOKABLE int getTempoForBeat(int partId, int beatNr);

      /**
       * @p TRUE if given @p partId of current composition is infinite
       */
  Q_INVOKABLE bool isPartInfinite(int partId);

      /**
       * Switches current infinite tempo part to the next one.
       */
  Q_INVOKABLE void switchInfinitePart();

  Q_INVOKABLE int meterOfPart(int partId);


signals:
  void finishSignal();
  void playingChanged();
  void beatTypeChanged();
  void meterChanged();
  void ringChanged();
  void ringTypeChanged();
  void tempoChanged();
  void nameTempoIdChanged();
  void tempoPartIdChanged();
  void variableTempoChanged();

protected:
  int                  p_ratioOfRate; /**< ratio of current sample rate to 48000 */

      /**
       * Returns path of given file name depending on OS.
       * Only bare file name is required, 'raw48-16' extension is added automatically
       */
  QString getRawFilePath(const QString& fName);

  void setNameTempoId(int ntId);
  void setNameIdByTempo(int t);

      /**
       * Change sample rate - on this value depends audio frames count.
       * TODO: There is no resampling implemented yet
       */
  void changeSampleRate(quint32 sr);

private slots:
  void outCallBack(char* data, unsigned int maxLen, unsigned int& wasRead);
  void playingFinishedSlot();
  void startPlayingSlot();


private:
  static TaudioOUT      *m_instance;
  bool                   m_initialized = false;
  quint32                m_sampleRate;
  bool                   m_callBackIsBussy;
  TabstractAudioOutput  *m_audioDevice;

  TspeedHandler         *m_speedHandler = nullptr;
  int                    m_playingPart = 0;
  int                    m_playingBeat = 1;
  int                    m_infiBeats = 0; /**< Beats number when current par is infinite */
  bool                   m_toNextPart = false; /**< TRUE when @p outCallBack will switch to next tempo part */
  int                    m_staticTempo;

  int                    m_samplPerBeat = 48000; /**< 1 sec - default for tempo 60 */
  int                    m_currSample = 0;
  bool                   m_goingToStop = false;
  TsoundData             m_beat;
  TsoundData             m_ring;
  bool                   m_doBell = false;
  qreal                  m_offsetSample = 0.0;
  qreal                  m_offsetCounter = 0.0;
  int                    m_missingSampleNr = 0;

  // properties
  bool                   m_playing = false;
  int                    m_beatType = -1;
  int                    m_meter = 0;
  bool                   m_doRing = false;
  int                    m_tempo = 60;
  int                    m_ringType = 0;
  int                    m_nameTempoId = 4;
  bool                   m_variableTempo = false;
};

#endif // TAUDIOOUT_H
