import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/cell_state.dart';
import 'models/game_layout.dart';
import 'systems/layout_system.dart';
import 'systems/placement_system.dart';

class DualBlocksGame extends FlameGame with TapCallbacks {
  GameLayout? layout;
  int score = 0;

  final List<List<CellState>> board = List.generate(
    GameConstants.boardSize,
    (_) => List.generate(GameConstants.boardSize, (_) => CellState.empty),
  );

  bool canPlace(int row, int col) {
    return PlacementSystem.canPlace(
      board: board,
      row: row,
      col: col,
    );
  }

  bool placeBlock(int row, int col) {
    final placed = PlacementSystem.placeBlock(
      board: board,
      row: row,
      col: col,
    );
    if (placed) score += 1;
    return placed;
  }

  math.Point<int>? screenToBoard(Offset p) {
    final currentLayout = layout;
    if (currentLayout == null) return null;
    return currentLayout.screenToBoard(p);
  }

  void tryPlaceFromScreen(Offset screenPosition) {
    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) return;
    placeBlock(row, col);
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

    tryPlaceFromScreen(screenPosition);
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
