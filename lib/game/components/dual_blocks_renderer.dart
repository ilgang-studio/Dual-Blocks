import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../models/block_shape.dart';
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
  static final Paint _slotPaint = Paint()..color = GameConstants.traySlotBackground;
  static final Paint _slotSelectedPaint = Paint()
    ..color = GameConstants.traySlotSelected.withValues(alpha: 0.35);
  static final Paint _shapePreviewPaint = Paint()..color = const Color(0xFFF59E0B);
  static final Paint _dragOkPaint = Paint()
    ..color = const Color(0xFF34D399).withValues(alpha: 0.65);
  static final Paint _dragBlockedPaint = Paint()
    ..color = const Color(0xFFF87171).withValues(alpha: 0.65);
  static final Paint _lineClearPaint = Paint()
    ..color = GameConstants.lineClearHighlight.withValues(alpha: 0.38);
  

  static void render({
    required Canvas canvas,
    required GameLayout layout,
    required int score,
    required List<List<CellState>> board,
    required List<BlockShape?> trayBlocks,
    required int? selectedTrayIndex,
    required BlockShape? dragShape,
    required Offset? dragScreenPosition,
    required bool dragCanPlace,
    required Set<int> clearRows,
    required Set<int> clearCols,
    required bool showClearHighlight,
  }) {
    _drawBoard(canvas, layout);
    _drawCells(canvas, layout, board);
    if (showClearHighlight) {
      _drawLineClearHighlight(
        canvas: canvas,
        layout: layout,
        clearRows: clearRows,
        clearCols: clearCols,
      );
    }
    _drawDragPreview(
      canvas: canvas,
      layout: layout,
      dragShape: dragShape,
      dragScreenPosition: dragScreenPosition,
      dragCanPlace: dragCanPlace,
    );
    _drawScore(canvas, layout, score);
    _drawGrid(canvas, layout);
    _drawBottomTray(canvas, layout);
    _drawTraySlots(
      canvas,
      layout,
      trayBlocks,
      selectedTrayIndex,
    );
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

  static void _drawTraySlots(
    Canvas canvas,
    GameLayout layout,
    List<BlockShape?> trayBlocks,
    int? selectedTrayIndex,
  ) {
    final slotRects = layout.traySlotRects();
    for (var i = 0; i < slotRects.length; i++) {
      final slotRect = slotRects[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
        _slotPaint,
      );
      if (selectedTrayIndex == i) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
          _slotSelectedPaint,
        );
      }

      final shape = i < trayBlocks.length ? trayBlocks[i] : null;
      if (shape != null) {
        _drawShapePreview(canvas, slotRect, shape);
      }
    }
  }

  static void _drawShapePreview(
    Canvas canvas,
    Rect slotRect,
    BlockShape shape,
  ) {
    const previewCell = 14.0;
    final points = shape.cells;

    var minX = points.first.x;
    var maxX = points.first.x;
    var minY = points.first.y;
    var maxY = points.first.y;

    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    final width = ((maxX - minX) + 1) * previewCell;
    final height = ((maxY - minY) + 1) * previewCell;
    final originX = slotRect.center.dx - (width / 2);
    final originY = slotRect.center.dy - (height / 2);

    for (final point in points) {
      final left = originX + ((point.x - minX) * previewCell);
      final top = originY + ((point.y - minY) * previewCell);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, previewCell - 2, previewCell - 2),
          const Radius.circular(3),
        ),
        _shapePreviewPaint,
      );
    }
  }

  static void _drawDragPreview({
    required Canvas canvas,
    required GameLayout layout,
    required BlockShape? dragShape,
    required Offset? dragScreenPosition,
    required bool dragCanPlace,
  }) {
    if (dragShape == null || dragScreenPosition == null) return;
    final boardPoint = layout.screenToBoard(dragScreenPosition);
    if (boardPoint == null) return;

    final paint = dragCanPlace ? _dragOkPaint : _dragBlockedPaint;
    for (final cell in dragShape.cells) {
      final col = boardPoint.x + cell.x;
      final row = boardPoint.y + cell.y;
      if (row < 0 ||
          row >= GameConstants.boardSize ||
          col < 0 ||
          col >= GameConstants.boardSize) {
        continue;
      }
      final rect = Rect.fromLTWH(
        layout.boardRect.left + col * layout.cellSize,
        layout.boardRect.top + row * layout.cellSize,
        layout.cellSize,
        layout.cellSize,
      );
      canvas.drawRect(rect, paint);
    }
  }

  static void _drawLineClearHighlight({
    required Canvas canvas,
    required GameLayout layout,
    required Set<int> clearRows,
    required Set<int> clearCols,
  }) {
    for (final row in clearRows) {
      final rect = Rect.fromLTWH(
        layout.boardRect.left,
        layout.boardRect.top + (row * layout.cellSize),
        layout.boardRect.width,
        layout.cellSize,
      );
      canvas.drawRect(rect, _lineClearPaint);
    }

    for (final col in clearCols) {
      final rect = Rect.fromLTWH(
        layout.boardRect.left + (col * layout.cellSize),
        layout.boardRect.top,
        layout.cellSize,
        layout.boardRect.height,
      );
      canvas.drawRect(rect, _lineClearPaint);
    }
  }
}
