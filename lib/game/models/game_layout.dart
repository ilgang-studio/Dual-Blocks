import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/game_constants.dart';

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
    return math.Point<int>(row, col);
  }
}
