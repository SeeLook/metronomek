// SPDX-FileCopyrightText: 2020-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QtQml/qqmlregistration.h>
#include <QtQuick/qquickpainteditem.h>

class QPainter;

/**
 * HACK
 * Somehow rendering big glyph of metronome shape by QML produces poor quality image.
 * To cheat that, this is QML item that simply paints that glyph.
 * Now the quality is brilliant.
 * It is worthy of an effort because using text and glyph painting
 * reduces launch time more than 30% over painting png images.
 * Also files size are smaller
 */
class TmetroShape : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

public:
    TmetroShape(QQuickItem *parent = nullptr);
    ~TmetroShape() override { }

    void paint(QPainter *painter) override;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;
};
