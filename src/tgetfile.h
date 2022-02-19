/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#ifndef TGETFILE_H
#define TGETFILE_H


#include <QtCore/qobject.h>
#include <QtNetwork/qnetworkaccessmanager.h>


/**
 * @class TgetFile downloads file from given @p fileAddr location.
 * Invoking constructor calls download process asynchronously.
 * @p downloadFinished() signal is emitted when done with @p success.
 * @p fileData() returns @p QByteArray with file data.
 * If @p expSize (expected download file size) is set (> 0)
 * @p progress(qreal) signal is emitted.
 */
class TgetFile : public QObject
{

  Q_OBJECT

public:
  explicit TgetFile(const QString& fileAddr, qint64 expSize, QObject* parent = nullptr);
  ~TgetFile() override;

  QByteArray& fileData() { return m_fileData; }

signals:
      /**
       * When emitted value is in range [0.0 - 1.0]
       * it represents download progress.
       * When it gets 1.0 or above - download is done.
       * Value below 0 (-1.0 usually) means net error.
       */
  void progress(qreal val);
  void downloadFinished(bool success);

protected:
  void progressSlot(qint64 bRead, qint16 bTotal);
  void downSlot(QNetworkReply* reply);

private:
  QNetworkAccessManager               m_netMan;
  QByteArray                          m_fileData;
  qint64                              m_expectedSize = 0;

};

#endif // TGETFILE_H
