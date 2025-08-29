/** This file is part of Metronomek                                  *
 * Copyright (C) 2020-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tmetroshape.h"

#include <QtGui/qguiapplication.h>
#include <QtGui/qpainter.h>
#include <QtGui/qpalette.h>

TmetroShape::TmetroShape(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    connect(qApp, &QGuiApplication::paletteChanged, this, [=] {
        update();
    });
}

void TmetroShape::paint(QPainter *painter)
{
    auto f = painter->font();
    f.setFamily(QStringLiteral("metronomek"));
    f.setPixelSize(height());
    painter->setFont(f);
    painter->setPen(qApp->palette().text().color());
    painter->drawText(QRect(0, 0, static_cast<int>(width()), static_cast<int>(height())), Qt::AlignLeft, QStringLiteral("\u00A3"));
}
