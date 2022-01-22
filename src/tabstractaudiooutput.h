/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TABSTRACTAUDIOOUTPUT_H
#define TABSTRACTAUDIOOUTPUT_H


#include <QtCore/qobject.h>


/**
 * @class TabstractAudioDevice is base class for audio output back-end.
 * Subclasses have to implement:
 * @p setAudioOutParams() - to create/initialize audio out
 *      and further change its parameters - like device name.
 * @p startPlaying() and @p stopPlaying() implements apparent functionality.
 *
 * @p feedAudio() signal is emitted when audio back-end wants data to play.
 * @p TaoudioOUT handles that and feed char* data stream with audio.
 *
 * It is assumed that audio data is 16 bits (@p qint16) and stereo (2 channels)
 */
class TabstractAudioDevice : public QObject
{

  Q_OBJECT

public:
  TabstractAudioDevice(QObject* parent = nullptr);

  virtual void setAudioOutParams() = 0;

      /**
       * Output device name - will be stored in config
       */
  virtual QString deviceName() const = 0;

      /**
       * Sets desired (used before) output device by its name.
       * Should invoke audio settings to approve device change
       */
  virtual void setDeviceName(const QString& devName) = 0;

  virtual void startPlaying() = 0;
  virtual void stopPlaying() = 0;

  bool isPlaying() const { return p_isPlaying; }

  quint32 sampleRate() const { return m_sampleRate; }
  void setSamplaRate(quint32 sr);

signals:

      /**
       * This signal has to be emitted by inheriting class!
       * @p char* is pointer to audio data that has to be fed
       * @p unsigne::int is data length but expressed in frames count,
       * so for 16 bits integer stereo data it is 4 * frames count
       *
       * @p unsigned::int& reference is returning value and depends on audio back-end:
       * For @p RtAudio it is callback return value (0 - continue, 1, 2 - to stop).
       * In @p Qt::Audio it is how many data frames were processed.
       * In any case: @p Tsound::outCallBack has to be aware of its meaning.
       * WARNING: This signal has to be connected using @p Qt::Qt::DirectConnection
       * to perform front-end callback routines in back-end thread.
       */
  void feedAudio(char*, unsigned int, unsigned int&);

  void sampleRateChanged();

protected:
  bool                  p_isPlaying = false;

private:
  quint32               m_sampleRate = 48000;

};

#endif // TABSTRACTAUDIOOUTPUT_H
