import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/cell_state.dart';
import 'models/game_layout.dart';
import 'systems/layout_system.dart';

class DualBlocksGame extends FlameGame with TapCallbacks {
  GameLayout? layout;
  int score = 0;

  final List<List<CellState>> board = List.generate(
    GameConstants.boardSize,
    (_) => List.generate(GameConstants.boardSize, (_) => CellState.empty),
  );

  bool _isInBounds(int row, int col) {
    return row >= 0 &&
        row < GameConstants.boardSize &&
        col >= 0 &&
        col < GameConstants.boardSize;
  }

  void debugFillCell(int row, int col) {
    if (!_isInBounds(row, col)) return;
    board[row][col] = CellState.filled;
  }

  math.Point<int>? screenToBoard(Offset p) {
    final currentLayout = layout;
    if (currentLayout == null) return null;
    return currentLayout.screenToBoard(p);
  }

  void debugFillFromScreen(Offset screenPosition) {
    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return;

    final col = boardPoint.x;
    final row = boardPoint.y;

    debugFillCell(row, col);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layout = LayoutSystem.calculate(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    layout = LayoutSystem.calculate(size);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final screenPosition = Offset(
      event.localPosition.x,
      event.localPosition.y,
    );

    debugFillFromScreen(screenPosition);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final currentLayout = layout;
    if (currentLayout == null) return;

    DualBlocksRenderer.render(
      canvas: canvas,
      layout: currentLayout,
      score: score,
      board: board,
    );
  }
}