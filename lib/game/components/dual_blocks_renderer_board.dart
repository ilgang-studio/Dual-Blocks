part of 'dual_blocks_renderer.dart';

void _drawBoard(Canvas canvas, GameLayout layout) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      layout.boardRect,
      const Radius.circular(GameConstants.cornerRadius),
    ),
    DualBlocksRenderer._boardPaint,
  );
}

void _drawCells(
  Canvas canvas,
  GameLayout layout,
  List<List<CellState>> board, {
  required BlockThemeMode themeMode,
  required double effectTime,
}) {
  for (int row = 0; row < GameConstants.boardSize; row++) {
    for (int col = 0; col < GameConstants.boardSize; col++) {
      final rect = Rect.fromLTWH(
        layout.boardRect.left + col * layout.cellSize,
        layout.boardRect.top + row * layout.cellSize,
        layout.cellSize,
        layout.cellSize,
      );

      if (board[row][col] == CellState.filled) {
        DualBlocksRenderer._cellFallbackPaint.color = _normalThemeColor(
          mode: themeMode,
          row: row,
          col: col,
          effectTime: effectTime,
        );
        canvas.drawRect(rect, DualBlocksRenderer._cellFallbackPaint);
      }
      if (board[row][col] == CellState.angelFilled) {
        canvas.drawRect(rect, DualBlocksRenderer._angelCellPaint);
      }
      if (board[row][col] == CellState.devilFilled) {
        canvas.drawRect(rect, DualBlocksRenderer._devilCellPaint);
      }
    }
  }
}

Color _normalThemeColor({
  required BlockThemeMode mode,
  required int row,
  required int col,
  required double effectTime,
}) {
  switch (mode) {
    case BlockThemeMode.solid:
      return GameConstants.normalBlockColor;
    case BlockThemeMode.custom:
      return const Color(0xFFF59E0B);
    case BlockThemeMode.rainbow:
      final palette = <Color>[
        const Color(0xFF22D3EE),
        const Color(0xFFA78BFA),
        const Color(0xFFF59E0B),
        const Color(0xFF34D399),
        const Color(0xFFF472B6),
      ];
      final index = (row + col + (effectTime * 1.8).floor()) % palette.length;
      return palette[index];
  }
}

void _drawGrid(Canvas canvas, GameLayout layout) {
  for (int col = 0; col <= GameConstants.boardSize; col++) {
    final x = layout.boardRect.left + (col * layout.cellSize);
    canvas.drawLine(
      Offset(x, layout.boardRect.top),
      Offset(x, layout.boardRect.bottom),
      DualBlocksRenderer._gridPaint,
    );
  }

  for (int row = 0; row <= GameConstants.boardSize; row++) {
    final y = layout.boardRect.top + (row * layout.cellSize);
    canvas.drawLine(
      Offset(layout.boardRect.left, y),
      Offset(layout.boardRect.right, y),
      DualBlocksRenderer._gridPaint,
    );
  }
}

void _drawDragPreview({
  required Canvas canvas,
  required GameLayout layout,
  required BlockShape? dragShape,
  required Offset? dragScreenPosition,
  required bool dragCanPlace,
}) {
  if (dragShape == null || dragScreenPosition == null) return;
  final boardPoint = layout.screenToBoard(dragScreenPosition);
  if (boardPoint == null) return;

  final borderColor = dragCanPlace
      ? const Color(0xFF22C55E)
      : const Color(0xFFEF4444);
  DualBlocksRenderer._dragPreviewBorderPaint.color = borderColor;
  DualBlocksRenderer._dragPreviewFillPaint.color = borderColor.withValues(
    alpha: 0.28,
  );
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
    canvas.drawRect(rect, DualBlocksRenderer._dragPreviewFillPaint);
    canvas.drawRect(
      rect.deflate(1),
      DualBlocksRenderer._dragPreviewBorderPaint,
    );
  }
}
