import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/cell_state.dart';
import 'models/game_layout.dart';
import 'systems/layout_system.dart';

class DualBlocksGame extends FlameGame {
  late GameLayout layout;
  int score = 0;
  final List<List<CellState>> board = List.generate(
    GameConstants.boardSize,
    (_) => List.generate(GameConstants.boardSize, (_) => CellState.empty),
  );

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

  math.Point<int>? screenToBoard(Offset p) {
    return layout.screenToBoard(p);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    DualBlocksRenderer.render(
      canvas: canvas,
      layout: layout,
      score: score,
      board: board,
    );
  }
}
