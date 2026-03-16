// SPDX-FileCopyrightText: 2020-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#include "tmetroshape.h"

#include <QtGui/qguiapplication.h>
#include <QtGui/qpainter.h>
#include <QtGui/qpalette.h>

using namespace Qt::Literals::StringLiterals;

TmetroShape::TmetroShape(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    qApp->installEventFilter(this);
}

void TmetroShape::paint(QPainter *painter)
{
    auto f = painter->font();
    f.setFamily("metronomek"_L1);
    f.setPixelSize(height());
    painter->setFont(f);
    painter->setPen(qApp->palette().text().color());
    painter->drawText(QRect(0, 0, static_cast<int>(width()), static_cast<int>(height())), Qt::AlignLeft, u"\u00A3"_s);
}

bool TmetroShape::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == qApp && event->type() == QEvent::ApplicationPaletteChange) {
        update();
    }
    return QObject::eventFilter(watched, event);
}
