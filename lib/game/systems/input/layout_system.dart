import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_constants.dart';
import '../../models/ui/game_layout.dart';

class LayoutSystem {
  static GameLayout calculate(Vector2 size) {
    final hudHeight = (size.y * 0.11).clamp(64.0, 88.0);
    const topInset = 8.0;
    const bottomInset = 12.0;
    const headerToBoardGap = 10.0;

    final usableWidth = size.x - (GameConstants.horizontalPadding * 2);
    final verticalBoardBudget =
        size.y -
        topInset -
        bottomInset -
        hudHeight -
        headerToBoardGap -
        GameConstants.sectionGap -
        GameConstants.trayHeight;

    final cellSize = math.min(
      usableWidth / GameConstants.boardSize,
      verticalBoardBudget / GameConstants.boardSize,
    );
    final boardPixels = cellSize * GameConstants.boardSize;

    final contentHeight =
        hudHeight +
        headerToBoardGap +
        boardPixels +
        GameConstants.sectionGap +
        GameConstants.trayHeight;
    final maxTop = size.y - contentHeight - bottomInset;
    final contentTop = ((size.y - contentHeight) / 2).clamp(topInset, maxTop);

    final boardLeft = (size.x - boardPixels) / 2;
    final boardTop = contentTop + hudHeight + headerToBoardGap;
    final boardRect = Rect.fromLTWH(
      boardLeft,
      boardTop,
      boardPixels,
      boardPixels,
    );

    final scoreRect = Rect.fromLTWH(
      boardLeft,
      contentTop,
      boardRect.width,
      hudHeight,
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
