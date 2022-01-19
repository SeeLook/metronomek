/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TSOUNDDATA_H
#define TSOUNDDATA_H


#include <QtCore/qstring.h>


/**
 * Buffer-like structure to keep and handle audio data
 */
class TsoundData {

public:
  TsoundData() {}
  TsoundData(const QString& rawFileName);
  TsoundData(qint16* other, int len);
  ~TsoundData();

  int size() const { return m_size + m_offset; }

      /**
       * sample value or null if out of scope
       */
  qint16 sampleAt(int samPos) const {
    if (samPos < m_offset)
      return 0;
    if (samPos < m_size + m_offset)
      return m_data[samPos - m_offset];
    return 0;
  }

  bool started() const { return m_started; }
  void setStarted(bool st) { m_started = st; }

      /**
       * Returns sample at current position and moves one step forward.
       * When position is out of scope, returns null
       */
  qint16 readSample() { m_pos++; return sampleAt(m_pos - 1); }

  int pos() const { return m_pos; }

      /**
       * Audio data offset - how many nulls are at the beginning.
       * It is used to move playing position of strongest data part,
       * which is expressed by @p peakAt() and obtained by @p findPeakPos()
       */
  quint32 offset() const { return m_offset; }
  void setOffset(quint32 off) { m_offset = off; }

      /**
       * Position of the strongest sample in @p m_data array
       * WITHOUT @p offset()
       */
  int peakAt() const { return m_peakAt; }

      /**
       * Resets position
       */
  void resetPos() { m_pos = 0; }
  bool hasNext() const { return m_pos < m_size + m_offset; }

  qint16* data() { return m_data; }

      /**
       * Reads audio data from raw audio file with given name
       */
  void setFile(const QString& rawFileName);

      /**
       * Copies @p len number of samples from @p other data.
       * Deletes actual data if it was set.
       */
  void copyData(qint16* other, int len);

  void deleteData();

      /**
       * Looks up for positions (sample number) of strongest sample.
       * Returns that value and also saves it into @p peakAt()
       */
  int findPeakPos();

private:
  qint16             *m_data = nullptr;
  int                 m_pos = 0;
  int                 m_size = 0;
  quint32             m_offset = 0;
  int                 m_peakAt = 0; /**< Unset by default */
  bool                m_started = false;
};

#endif // TSOUNDDATA_H
