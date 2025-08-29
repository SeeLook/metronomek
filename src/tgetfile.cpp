/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tgetfile.h"

#include <QtCore/qdebug.h>
#include <QtNetwork/qnetworkreply.h>
#include <QtNetwork/qsslsocket.h>

TgetFile::TgetFile(const QString &fileAddr, qint64 expSize, QObject *parent)
    : QObject(parent)
    , m_expectedSize(expSize)
{
    if (!QSslSocket::supportsSsl()) {
        qDebug() << "[TgetFile] No SSL support";
        if (m_expectedSize > 0)
            emit progress(-1.0); // hide progress bar immediately
        emit downloadFinished(false);
        return;
    }

    connect(&m_netMan, &QNetworkAccessManager::finished, this, &TgetFile::downSlot);

    m_netMan.setRedirectPolicy(QNetworkRequest::NoLessSafeRedirectPolicy);
    QNetworkRequest request((QUrl(fileAddr)));
    request.setRawHeader("user-agent", "Metronomek 1.0"); // HACK: use such an agent to work with sourceforge

// handle Windows SSL handshake error
#if defined(Q_OS_WIN)
    auto conf = request.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    request.setSslConfiguration(conf);
#endif

    m_reply = m_netMan.get(request);
    connect(m_reply, &QNetworkReply::errorOccurred, this, [=](QNetworkReply::NetworkError e) {
        qDebug() << "[TgetFile]" << e << m_reply->errorString();
        if (m_expectedSize > 0)
            emit progress(-1.0); // hide progress bar immediately
        emit downloadFinished(false);
    });
    if (m_expectedSize > 0)
        connect(m_reply, &QNetworkReply::downloadProgress, this, &TgetFile::progressSlot);
}

TgetFile::~TgetFile()
{
}

void TgetFile::abort()
{
    if (!m_aborted) {
        m_aborted = true;
        if (m_reply)
            m_reply->abort();
    }
}

void TgetFile::progressSlot(qint64 bRead, qint16 bTotal)
{
    Q_UNUSED(bTotal)
    if (bRead > 0)
        emit progress(static_cast<qreal>(bRead) / static_cast<qreal>(m_expectedSize));
}

void TgetFile::downSlot(QNetworkReply *reply)
{
    if (!m_aborted) {
        if (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 301 || reply->rawHeaderList().contains("Location")) {
            QNetworkRequest req(reply->header(QNetworkRequest::LocationHeader).toString());
            auto r = m_netMan.get(req);
            if (m_expectedSize > 0)
                connect(r, &QNetworkReply::downloadProgress, this, &TgetFile::progressSlot);
            reply->deleteLater();
            return;
        }
    }
    bool success = false;
    if (!m_aborted && reply->size()) {
        m_fileData = reply->readAll();
        success = true;
    }
    reply->deleteLater();
    emit downloadFinished(success);
}
