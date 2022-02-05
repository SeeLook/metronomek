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
 */
class TgetFile : public QObject
{

  Q_OBJECT

public:
  explicit TgetFile(const QString& fileAddr, QObject* parent = nullptr);
  ~TgetFile() override;

  QByteArray& fileData() { return m_fileData; }

signals:
  void downloadFinished(bool success);

protected:
  void downSlot(QNetworkReply* reply);

private:
  QNetworkAccessManager               m_netMan;
  QByteArray                          m_fileData;

};

#endif // TGETFILE_H
