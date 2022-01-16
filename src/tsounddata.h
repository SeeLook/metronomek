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

  int size() const { return m_size; }

      /**
       * sample value or null if out of scope
       */
  qint16 sampleAt(int samPos) const { return samPos < m_size ? m_data[samPos] : 0; }

  bool started() const { return m_started; }
  void setStarted(bool st) { m_started = st; }

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
  bool hasNext() const { return m_pos < m_size; }

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

private:
  qint16             *m_data = nullptr;
  int                 m_pos = 0;
  int                 m_size = 0;
  bool                m_started = false;
};

#endif // TSOUNDDATA_H
