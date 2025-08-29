/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tsounddata.h"

#include <QtCore/qdatastream.h>
#include <QtCore/qdebug.h>
#include <QtCore/qfile.h>

TsoundData::TsoundData(const QString &rawFileName)
{
    if (!rawFileName.isEmpty())
        setFile(rawFileName);
}

TsoundData::TsoundData(qint16 *other, int len)
{
    copyData(other, len);
}

TsoundData::~TsoundData()
{
    deleteData();
}

void TsoundData::deleteData()
{
    if (m_data && m_size) {
        delete m_data;
        m_data = nullptr;
        m_size = 0;
        m_offset = 0;
        m_peakAt = 0;
    }
}

void TsoundData::setFile(const QString &rawFileName)
{
    deleteData();
    if (rawFileName.isEmpty())
        return;

    QFile rawFile(rawFileName);
    if (rawFile.exists()) {
        rawFile.open(QIODevice::ReadOnly);
        m_size = static_cast<int>(rawFile.size() / 2);
        m_data = new qint16[m_size];
        QDataStream beatStream(&rawFile);
        beatStream.readRawData(reinterpret_cast<char *>(m_data), m_size * 2);
    } else {
        m_size = 0;
        qDebug() << "[TsoundData] sound file" << rawFileName << "doesn't exist";
    }
}

void TsoundData::copyData(qint16 *other, int len)
{
    deleteData();
    m_size = len;
    m_data = new qint16[len];
    std::copy(other, other + len, m_data);
}

void TsoundData::readData(QDataStream &in, quint32 len)
{
    deleteData();
    m_size = len / 2;
    m_data = new qint16[m_size];
    auto read = in.readRawData(reinterpret_cast<char *>(m_data), len);
    if (read != len)
        qDebug() << "[TsoundData] Read error!";
}

int TsoundData::findPeakPos()
{
    qint16 max = 0;
    qint16 sample;
    for (int s = 0; s < m_size; ++s) {
        sample = qAbs(m_data[s]);
        if (sample > max) {
            max = sample;
            m_peakAt = s;
        }
    }
    return m_peakAt;
}
