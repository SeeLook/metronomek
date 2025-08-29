/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TNUMERALSPECTRUM_H
#define TNUMERALSPECTRUM_H

#include <QtQuick/qquickpainteditem.h>

class TsoundData;

/**
 *
 */
class TnumeralSpectrum : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(int nr READ nr WRITE setNr NOTIFY nrChanged)
    Q_PROPERTY(QString recMessage READ recMessage NOTIFY recMessageChanged)

public:
    explicit TnumeralSpectrum(QQuickItem *parent = nullptr);
    ~TnumeralSpectrum() override;

    int nr() const { return m_nr; }
    void setNr(int nr);

    QString recMessage() const { return m_recMessage; }

    void paint(QPainter *painter) override;

    TsoundData *numeral() { return m_numData; }
    void setNumeral(TsoundData *numData = nullptr);

    void copyData(qint16 *numData, int len);

    void startRecording();

signals:
    void nrChanged(int nr);
    void recMessageChanged();

protected:
    void setRecMessage(const QString &m);

private:
    int m_nr = -1;
    TsoundData *m_numData = nullptr;
    QString m_recMessage;
};

#endif // TNUMERALSPECTRUM_H
