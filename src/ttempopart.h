// SPDX-FileCopyrightText: 2021-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QtCore/qeasingcurve.h>
#include <QtCore/qobject.h>
#include <QtQml/qqmlregistration.h>

class QXmlStreamWriter;
class QXmlStreamReader;

/**
 * @class TtempoPart describes tempo change.
 * Properties @p initTempo() and @p targetTempo()
 * and duration expressed in @p bars, @p beats or @p seconds
 * define how Metronomek ticks.
 */
class TtempoPart : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(TempoPart)
    QML_UNCREATABLE("")

    Q_PROPERTY(int nr READ nr NOTIFY nrChanged)
    Q_PROPERTY(int targetTempo READ targetTempo WRITE setTargetTempo NOTIFY targetTempoChanged)
    Q_PROPERTY(int initTempo READ initTempo WRITE setInitTempo NOTIFY initTempoChanged)
    Q_PROPERTY(int meter READ meter WRITE setMeter NOTIFY meterChanged)
    Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY updateDuration)
    Q_PROPERTY(int beats READ beats WRITE setBeats NOTIFY updateDuration)
    Q_PROPERTY(int seconds READ seconds WRITE setSeconds NOTIFY updateDuration)
    Q_PROPERTY(bool infinite READ infinite WRITE setInfinite NOTIFY infiniteChanged)
    Q_PROPERTY(QString tempoText READ tempoText NOTIFY tempoTextChanged)

public:
    TtempoPart(int partNr = 0, QObject *parent = nullptr);
    ~TtempoPart() override;

    enum PartType : quint8 {
        P_Finite = 0,
        P_Infinite = 1,
        P_InfinitEnds = 128, /**< When infinite part is going to stop at the end of measure. */
    };
    Q_ENUM(PartType)

    int nr() const { return m_nr; }
    void setNr(int nr);

    int initTempo() const { return m_initTempo; }
    void setInitTempo(int it);

    int targetTempo() const { return m_targetTempo; }
    void setTargetTempo(int tt);

    int meter() const { return m_meter; }
    void setMeter(int m);

    void setTempos(int init, int target);

    QEasingCurve::Type speedProfile() const { return m_speedProfile.type(); }
    void setSpeedProfile(QEasingCurve::Type type);

    int bars() const { return m_bars; }
    void setBars(int brs);
    int beats() const { return m_beats; }
    void setBeats(int bts);
    int seconds() const { return m_seconds; }
    void setSeconds(int sec);

    bool infinite() const { return m_infinite & P_Infinite; }
    void setInfinite(bool inf);
    void stopInfinite();
    void resetStopInfinite();

    enum EspeedType { SpeedStatic = 0, SpeedAccel = 1, SpeedRall = 2 };
    Q_ENUM(EspeedType)

    EspeedType speedType() const
    {
        if (m_initTempo == m_targetTempo)
            return SpeedStatic;
        return m_initTempo < m_targetTempo ? SpeedAccel : SpeedRall;
    }

    /**
     * Returns tempo at given beat number.
     * But if @p beatNr is bigger than beats in the part
     * returns 0.
     */
    int getTempoForBeat(int beatNr);

    QString tempoText() const;

    void writeToXML(QXmlStreamWriter &xml);
    void readFromXML(QXmlStreamReader &xml);

    void copy(TtempoPart *other);
    Q_INVOKABLE void reset();

signals:
    void nrChanged();
    void targetTempoChanged();
    void initTempoChanged();
    void meterChanged();
    void updateDuration();
    void tempoTextChanged();
    void infiniteChanged();

protected:
    void calculateDuration();

private:
    int m_nr = 0;
    int m_targetTempo = 60;
    int m_initTempo = 60;
    int m_meter = 4;
    int m_bars = 1, m_beats = 4, m_seconds = 4;
    QEasingCurve m_speedProfile; /**< By default it is linear */
    quint8 m_infinite = P_Finite;
};
