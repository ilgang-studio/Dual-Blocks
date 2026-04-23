import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../config/game_constants.dart';
import 'fate_effect.dart';

class GameLayout {
  const GameLayout({
    required this.cellSize,
    required this.boardRect,
    required this.scoreRect,
    required this.bottomTrayRect,
  });

  final double cellSize;
  final Rect boardRect;
  final Rect scoreRect;
  final Rect bottomTrayRect;

  math.Point<int>? screenToBoard(Offset point) {
    if (!boardRect.contains(point)) return null;

    final col = ((point.dx - boardRect.left) / cellSize).floor();
    final row = ((point.dy - boardRect.top) / cellSize).floor();

    if (row < 0 ||
        row >= GameConstants.boardSize ||
        col < 0 ||
        col >= GameConstants.boardSize) {
      return null;
    }
    // Keep Cartesian semantics: x = column, y = row.
    return math.Point<int>(col, row);
  }

  int? screenToTrayIndex(Offset point) {
    final slots = traySlotRects();
    for (var i = 0; i < slots.length; i++) {
      if (slots[i].contains(point)) return i;
    }
    return null;
  }

  List<Rect> traySlotRects() {
    final totalGap = GameConstants.traySlotGap * (GameConstants.traySlotCount - 1);
    final innerWidth = bottomTrayRect.width - (GameConstants.trayInnerPadding * 2);
    final slotSize = (innerWidth - totalGap) / GameConstants.traySlotCount;
    final top = bottomTrayRect.top +
        ((bottomTrayRect.height - slotSize) / 2);

    return List<Rect>.generate(GameConstants.traySlotCount, (index) {
      final left = bottomTrayRect.left +
          GameConstants.trayInnerPadding +
          (index * (slotSize + GameConstants.traySlotGap));
      return Rect.fromLTWH(left, top, slotSize, slotSize);
    });
  }

  Rect angelChoiceRect() {
    const width = 78.0;
    const height = 18.0;
    final left = scoreRect.right - (width * 2) - 16;
    final top = scoreRect.top + 28;
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect devilChoiceRect() {
    const width = 78.0;
    const height = 18.0;
    final left = scoreRect.right - width - 8;
    final top = scoreRect.top + 28;
    return Rect.fromLTWH(left, top, width, height);
  }

  FateType? screenToFateChoice(Offset point) {
    if (angelChoiceRect().contains(point)) return FateType.angel;
    if (devilChoiceRect().contains(point)) return FateType.devil;
    return null;
  }
}
