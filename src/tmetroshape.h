/** This file is part of Metronomek                                  *
 * Copyright (C) 2020 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#ifndef TMETROSHAPE_H
#define TMETROSHAPE_H


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

public:

  TmetroShape(QQuickItem* parent = nullptr);
  ~TmetroShape() override {}

  void paint(QPainter* painter) override;

};

#endif // TMETROSHAPE_H
