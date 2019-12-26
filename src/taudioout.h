/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TAUDIOOUT_H
#define TAUDIOOUT_H


#include <QtCore/qstringlist.h>
#include <QtMultimedia/qaudio.h>
#include <QtMultimedia/qaudiodeviceinfo.h>


class QAudioOutput;
class TaudioBuffer;


/**
 * 
 */
class TaudioOUT : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool playing READ playing WRITE setPlaying NOTIFY playingChanged)
  Q_PROPERTY(int beatType READ beatType WRITE setBeatType NOTIFY beatTypeChanged)

public:
  TaudioOUT(QObject* parent = nullptr);
  ~TaudioOUT() override;

  static QStringList getAudioDevicesList();
  static QString outputName() { return m_devName; }
  static TaudioOUT* instance() { return m_instance; }

  void init();

  Q_INVOKABLE void startTicking();
  Q_INVOKABLE void stopTicking();

  void setAudioOutParams();

  void setTempo(int t);

  bool playing() const { return m_playing; }
  void setPlaying(bool pl);

  enum EbeatType {
    Beat_Classic, Beat_Classic2, Beat_Snap, Beat_Parapet, Beat_Sticks,
    Beat_TypesCount
  };
  Q_ENUM(EbeatType)

  Q_INVOKABLE int beatTypeCount() const { return static_cast<int>(Beat_TypesCount); }
  int beatType() const { return m_beatType; }
  void setBeatType(int bt);
  QString getBeatFileName(EbeatType bt);
  Q_INVOKABLE QString getBeatName(int bt);

protected:
  void createOutputDevice();  

signals:
  void finishSignal();
  void playingChanged();
  void beatTypeChanged();

protected:
  int                  ratioOfRate; // ratio of current sample rate to 48000

private slots:
  void outCallBack(char* data, qint64 maxLen, qint64& wasRead);
//   void updateSlot() { setAudioOutParams(); }
  void playingFinishedSlot();
  void stateChangedSlot(QAudio::State state);
  void startPlayingSlot();


private:
  static QString      m_devName;
  static TaudioOUT   *m_instance;
  bool                m_initialized = false;
  int                 m_bufferFrames, m_sampleRate;
  bool                m_callBackIsBussy;
  QAudioOutput       *m_audioOUT;
  TaudioBuffer       *m_buffer;
  QAudioDeviceInfo    m_deviceInfo;
  qint16             *m_beatData = nullptr;
  int                 m_beatSamples = 0;
  int                 m_samplPerBeat = 48000; /**< 1 sec - default for tempo 60 */
  int                 m_currSample = 0;
  bool                m_playing = false;
  int                 m_beatType = -1;
  bool                m_goingToStop = false;
};

#endif // TAUDIOOUT_H
