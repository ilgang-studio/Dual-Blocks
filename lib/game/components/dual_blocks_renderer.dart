import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../models/cell_state.dart';
import '../models/game_layout.dart';

class DualBlocksRenderer {
  static final Paint _boardPaint = Paint()..color = GameConstants.boardBackground;
  static final Paint _gridPaint = Paint()
    ..color = GameConstants.gridLine
    ..strokeWidth = 1;
  static final Paint _trayPaint = Paint()..color = GameConstants.trayBackground;
  static final Paint _scorePaint = Paint()..color = GameConstants.scoreBackground;
  static final Paint _cellPaint = Paint()
    ..color = Colors.blue; // 테스트용
  

  static void render({
    required Canvas canvas,
    required GameLayout layout,
    required int score,
    required List<List<CellState>> board,
  }) {
    _drawBoard(canvas, layout);
    _drawCells(canvas, layout, board);
    _drawScore(canvas, layout, score);
    _drawGrid(canvas, layout);
    _drawBottomTray(canvas, layout);
  }

  static void _drawBoard(Canvas canvas, GameLayout layout) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.boardRect,
        const Radius.circular(GameConstants.cornerRadius),
      ),
      _boardPaint,
    );
  }
  static void _drawCells(
  Canvas canvas,
  GameLayout layout,
  List<List<CellState>> board,
  ) {
    for (int row = 0; row < GameConstants.boardSize; row++) {
      for (int col = 0; col < GameConstants.boardSize; col++) {
        if (board[row][col] == CellState.filled) {
          final rect = Rect.fromLTWH(
            layout.boardRect.left + col * layout.cellSize,
            layout.boardRect.top + row * layout.cellSize,
            layout.cellSize,
            layout.cellSize,
          );

          canvas.drawRect(rect, _cellPaint);
        }
      }
    }
  }

  static void _drawScore(Canvas canvas, GameLayout layout, int score) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.scoreRect,
        const Radius.circular(GameConstants.cornerRadius),
      ),
      _scorePaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        layout.scoreRect.center.dx - (textPainter.width / 2),
        layout.scoreRect.center.dy - (textPainter.height / 2),
      ),
    );
  }

  static void _drawGrid(Canvas canvas, GameLayout layout) {
    for (int col = 0; col <= GameConstants.boardSize; col++) {
      final x = layout.boardRect.left + (col * layout.cellSize);
      canvas.drawLine(
        Offset(x, layout.boardRect.top),
        Offset(x, layout.boardRect.bottom),
        _gridPaint,
      );
    }

    for (int row = 0; row <= GameConstants.boardSize; row++) {
      final y = layout.boardRect.top + (row * layout.cellSize);
      canvas.drawLine(
        Offset(layout.boardRect.left, y),
        Offset(layout.boardRect.right, y),
        _gridPaint,
      );
    }
  }

  static void _drawBottomTray(Canvas canvas, GameLayout layout) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.bottomTrayRect,
        const Radius.circular(GameConstants.cornerRadius),
      ),
      _trayPaint,
    );
  }
}
