/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TRTAUDIOOUT_H
#define TRTAUDIOOUT_H


#include "tabstractaudiodevice.h"
#include "rtaudio/RtAudio.h"


/**
 * @class TRtAudioDevice is Linux/Mac/Windows back-end of Metronomek audio
 */
class TRtAudioDevice : public TabstractAudioDevice
{

  Q_OBJECT

public:
  TRtAudioDevice(QObject* parent = nullptr);
  ~TRtAudioDevice() override;

  static QStringList getAudioOutDevicesList();

  static RtAudio* rtDevice() { return m_rtAduio; }

  void setAudioOutParams() override;

  QString deviceName() const override { return m_outDevName; }
  void setDeviceName(const QString& devName) override;

  void startPlaying() override;
  void startRecording() override;
  void stop() override;

  void setAudioInParams();

protected:
      /**
       * Creates RtAudio instance. Once for whole application.
       */
  static void createRtAudio();

      /**
       * Returns current RtAudio API is instance exists or @p RtAudio::UNSPECIFIED
       */
  static RtAudio::Api getCurrentApi();

  static bool getDeviceInfo(RtAudio::DeviceInfo &devInfo, unsigned int id);

      /**
      * Converts device name of @p devInf determining proper encoding which depends on current API.
      */
  static QString convDevName(RtAudio::DeviceInfo& devInf) {
    if (getCurrentApi() == RtAudio::WINDOWS_WASAPI)
      return QString::fromUtf8(devInf.name.data());
    else
      return QString::fromLocal8Bit(devInf.name.data());
  }

      /**
       * Returns number of available audio devices or 0 if none or error occurred.
       */
  static unsigned int getDeviceCount();

  static int getDefaultOutput();
  static int getDefaultInput();

  bool openStream();
  bool isOpened();
  bool startStream();

  void stopStream();
  void closeStream();
  void abortStream();

  static int outCallBack(void *outBuffer, void*, unsigned int nBufferFrames, double, RtAudioStreamStatus status, void*);

  static void emitFeedAudio(char* outBuffer, unsigned int nBufferFrames, unsigned int& retVal) {
    emit m_instance->feedAudio(outBuffer, nBufferFrames, retVal);
  }

  static int inCallBack(void*, void* inBuffer, unsigned int nBufferFrames, double, RtAudioStreamStatus status, void*);

  static void emitTakeAudio(char* inBuffer, unsigned int nBufferFrames, unsigned int& retVal) {
    emit m_instance->takeAudio(inBuffer, nBufferFrames, retVal);
  }

  quint32 determineSampleRate(RtAudio::DeviceInfo& devInfo);

private:
  static TRtAudioDevice                  *m_instance;
  static RtAudio                         *m_rtAduio;

  bool                                    m_isAlsaDefault = false;
  RtAudio::StreamOptions                 *m_streamOptions = nullptr;
  RtAudio::StreamParameters              *m_outParams = nullptr;
  RtAudio::StreamParameters              *m_inParams = nullptr;
  QString                                 m_outDevName = QLatin1String("anything");
  QString                                 m_inDevName = QLatin1String("anything");
};

#endif // TRTAUDIOOUT_H
