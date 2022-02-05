/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "tgetfile.h"

#include <QtNetwork/qnetworkreply.h>
#include <QtCore/qdebug.h>


TgetFile::TgetFile(const QString& fileAddr, QObject* parent) :
  QObject(parent)
{
  connect(&m_netMan, &QNetworkAccessManager::finished, this, &TgetFile::downSlot);

  m_netMan.setRedirectPolicy(QNetworkRequest::SameOriginRedirectPolicy);
  QNetworkRequest request((QUrl(fileAddr)));
  request.setRawHeader("user-agent", "Metronomek"); // HACK: use such an agent to work with sourceforge
  m_netMan.get(request);
}


TgetFile::~TgetFile()
{
}


void TgetFile::downSlot(QNetworkReply* reply) {
  if (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 301 || reply->rawHeaderList().contains("Location")) {
    QNetworkRequest req(reply->header(QNetworkRequest::LocationHeader).toString());
    m_netMan.get(req);
    return;
  }
  qDebug() << reply->error();
  bool success = false;
  if (reply->size()) {
      m_fileData = reply->readAll();
      success = true;
  }
  reply->deleteLater();
  emit downloadFinished(success);
}


