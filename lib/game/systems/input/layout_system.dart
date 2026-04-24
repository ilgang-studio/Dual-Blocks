import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_constants.dart';
import '../../models/ui/game_layout.dart';

class LayoutSystem {
  static GameLayout calculate(Vector2 size) {
    final usableWidth = size.x - (GameConstants.horizontalPadding * 2);
    final usableHeight =
        size.y -
        GameConstants.topPadding -
        GameConstants.trayHeight -
        GameConstants.sectionGap -
        GameConstants.outerBottomPadding;

    final cellSize = math.min(
      usableWidth / GameConstants.boardSize,
      usableHeight / GameConstants.boardSize,
    );
    final boardPixels = cellSize * GameConstants.boardSize;

    final boardLeft = (size.x - boardPixels) / 2;
    final boardTop = GameConstants.topPadding;
    final boardRect = Rect.fromLTWH(
      boardLeft,
      boardTop,
      boardPixels,
      boardPixels,
    );

    final scoreRect = Rect.fromLTWH(
      boardLeft,
      boardRect.top - GameConstants.scoreGapFromBoard,
      boardRect.width,
      GameConstants.scoreHeight,
    );

    final bottomTrayRect = Rect.fromLTWH(
      GameConstants.horizontalPadding,
      boardRect.bottom + GameConstants.sectionGap,
      size.x - (GameConstants.horizontalPadding * 2),
      GameConstants.trayHeight,
    );

    return GameLayout(
      cellSize: cellSize,
      boardRect: boardRect,
      scoreRect: scoreRect,
      bottomTrayRect: bottomTrayRect,
    );
  }
}
