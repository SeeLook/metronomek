// SPDX-FileCopyrightText: 2021-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#include "ttempopart.h"
#include "tsound.h"

#include <QtCore/qdebug.h>
#include <QtCore/qxmlstream.h>

using namespace Qt::Literals::StringLiterals;

TtempoPart::TtempoPart(int partNr, QObject *parent)
    : QObject(parent)
    , m_nr(partNr)
{
}

TtempoPart::~TtempoPart()
{
}

void TtempoPart::setNr(int nr)
{
    if (nr != m_nr) {
        m_nr = nr;
        emit nrChanged();
        emit tempoTextChanged();
    }
}

void TtempoPart::setInitTempo(int it)
{
    if (it != m_initTempo) {
        m_initTempo = it;
        calculateDuration();
        emit initTempoChanged();
        emit updateDuration();
        emit tempoTextChanged();
        if (m_initTempo != m_targetTempo && m_infinite) {
            m_infinite = false;
            emit infiniteChanged();
        }
    }
}

void TtempoPart::setTargetTempo(int tt)
{
    if (tt != m_targetTempo) {
        m_targetTempo = tt;
        calculateDuration();
        emit targetTempoChanged();
        emit updateDuration();
        emit tempoTextChanged();
        if (m_initTempo != m_targetTempo && m_infinite) {
            m_infinite = false;
            emit infiniteChanged();
        }
    }
}

void TtempoPart::setTempos(int init, int target)
{
    setInitTempo(init);
    setTargetTempo(target);
}

void TtempoPart::setMeter(int m)
{
    if (m != m_meter) {
        m_meter = m;
        m_beats = m_bars * m_meter;
        calculateDuration();
        emit updateDuration();
        emit meterChanged();
    }
}

void TtempoPart::setBars(int brs)
{
    if (brs != m_bars) {
        m_bars = brs;
        m_beats = m_bars * m_meter;
        calculateDuration();
        emit updateDuration();
    }
}

void TtempoPart::setBeats(int bts)
{
    if (bts != m_beats) {
        m_beats = bts;
        m_bars = m_beats / m_meter + (m_beats % m_meter > 0 ? 1 : 0);
        calculateDuration();
        emit updateDuration();
    }
}

void TtempoPart::setSeconds(int sec)
{
    if (sec != m_seconds) {
        calculateDuration();
    }
}

void TtempoPart::setInfinite(bool inf)
{
    if (inf != m_infinite) {
        m_infinite = inf;
        emit infiniteChanged();
    }
}

void TtempoPart::setSpeedProfile(QEasingCurve::Type type)
{
    if (m_speedProfile.type() != type) {
        m_speedProfile.setType(type);
    }
}

int TtempoPart::getTempoForBeat(int beatNr)
{
    if (m_initTempo == m_targetTempo && m_infinite)
        return m_initTempo;

    if (beatNr > m_beats)
        return 0;

    int span = qAbs(m_initTempo - m_targetTempo);
    int tempoDiff = qRound(m_speedProfile.valueForProgress(static_cast<qreal>(beatNr) / static_cast<qreal>(m_beats)) * span);
    int dir = m_initTempo < m_targetTempo ? 1 : -1;
    return qBound(40, m_initTempo + dir * tempoDiff, 240);
}

QString TtempoPart::tempoText() const
{
    bool ch = m_initTempo != m_targetTempo;
    QString speedUpOrDown;
    if (ch) {
        if (m_initTempo < m_targetTempo)
            speedUpOrDown = tr("accelerando", "This is official, glob wide music term, so it shouldn't be translated.");
        else
            speedUpOrDown = tr("rallentando", "This is official, glob wide music term, so it shouldn't be translated.");
        speedUpOrDown.prepend("  ("_L1);
        speedUpOrDown.append(")"_L1);
    }
    return QString("%1. ").arg(m_nr) + tr("Tempo") + QString(": %1%2").arg(m_initTempo).arg(ch ? QString(" -> %1").arg(m_targetTempo) : QString())
        + speedUpOrDown;
}

void TtempoPart::writeToXML(QXmlStreamWriter &xml)
{
    xml.writeStartElement("tempoChange"_L1);
    xml.writeTextElement("init"_L1, QString::number(m_initTempo));
    xml.writeTextElement("target"_L1, QString::number(m_targetTempo));
    xml.writeTextElement("meter"_L1, QString::number(m_meter));
    xml.writeTextElement("beats"_L1, QString::number(m_beats));
    if (m_infinite)
        xml.writeEmptyElement("infinite"_L1);
    xml.writeEndElement(); // tempo
}

void TtempoPart::readFromXML(QXmlStreamReader &xml)
{
    while (xml.readNextStartElement()) {
        if (xml.name() == "init"_L1)
            m_initTempo = qBound(40, xml.readElementText().toInt(), 240);
        else if (xml.name() == "target"_L1)
            m_targetTempo = qBound(40, xml.readElementText().toInt(), 240);
        else if (xml.name() == "meter"_L1)
            m_meter = qBound(1, xml.readElementText().toInt(), 12);
        else if (xml.name() == "beats"_L1)
            setBeats(qMax(1, xml.readElementText().toInt()));
        else if (xml.name() == "infinite"_L1) {
            if (m_initTempo == m_targetTempo)
                m_infinite = true;
            else
                qDebug() << "[TtempoPart] Duration sets to infinite but initial and target tempos are different!";
            xml.skipCurrentElement();
        } else
            xml.skipCurrentElement();
    }
}

void TtempoPart::copy(TtempoPart *other)
{
    m_initTempo = other->initTempo();
    m_targetTempo = other->targetTempo();
    m_meter = other->meter();
    m_beats = other->beats();
    m_bars = other->bars();
    m_seconds = other->seconds();
    m_infinite = other->infinite();
    m_speedProfile = other->speedProfile();
}

void TtempoPart::reset()
{
    setTempos(SOUND->tempo(), SOUND->tempo());
    //   setMeter(SOUND->meter());
    setBars(1);
    setInfinite(false);
}

// #################################################################################################
// ###################                PROTECTED         ############################################
// #################################################################################################

void TtempoPart::calculateDuration()
{
    int averageTempo = (m_initTempo + m_targetTempo) / 2;
    m_seconds = qRound((60.0 / static_cast<qreal>(averageTempo)) * m_beats);
}
