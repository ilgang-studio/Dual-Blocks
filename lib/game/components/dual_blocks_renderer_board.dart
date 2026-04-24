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
  required List<List<int?>> boardColorIndices,
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
        var fillColor = _normalThemeColor(
          mode: themeMode,
          row: row,
          col: col,
          effectTime: effectTime,
        );
        if (themeMode == BlockThemeMode.rainbow) {
          final colorIndex = boardColorIndices[row][col];
          if (colorIndex != null) {
            fillColor = _rainbowPaletteColor(colorIndex);
          }
        }
        DualBlocksRenderer._cellFallbackPaint.color = fillColor;
        _drawBeveledBlockTile(
          canvas: canvas,
          rect: rect,
          color: fillColor,
          cornerRadius: 2.5,
        );
      }
      if (board[row][col] == CellState.angelFilled) {
        _drawBeveledBlockTile(
          canvas: canvas,
          rect: rect,
          color: DualBlocksRenderer._angelCellPaint.color,
          cornerRadius: 2.5,
        );
      }
      if (board[row][col] == CellState.devilFilled) {
        _drawBeveledBlockTile(
          canvas: canvas,
          rect: rect,
          color: DualBlocksRenderer._devilCellPaint.color,
          cornerRadius: 2.5,
        );
      }
    }
  }
}

void _drawBeveledBlockTile({
  required Canvas canvas,
  required Rect rect,
  required Color color,
  required double cornerRadius,
}) {
  final base = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
  final inner = rect.deflate(0.6);
  final innerRRect = RRect.fromRectAndRadius(
    inner,
    Radius.circular(cornerRadius * 0.85),
  );

  DualBlocksRenderer._cellFallbackPaint.color = color;
  canvas.drawRRect(base, DualBlocksRenderer._cellFallbackPaint);

  DualBlocksRenderer._blockBevelHighlightPaint.shader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.34),
      Colors.white.withValues(alpha: 0.08),
      Colors.transparent,
    ],
    stops: const [0.0, 0.32, 1.0],
  ).createShader(inner);
  canvas.drawRRect(innerRRect, DualBlocksRenderer._blockBevelHighlightPaint);

  DualBlocksRenderer._blockBevelShadowPaint.shader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.transparent,
      Colors.black.withValues(alpha: 0.1),
      Colors.black.withValues(alpha: 0.28),
    ],
    stops: const [0.0, 0.58, 1.0],
  ).createShader(inner);
  canvas.drawRRect(innerRRect, DualBlocksRenderer._blockBevelShadowPaint);

  final topEdgeRect = Rect.fromLTWH(
    inner.left + 1,
    inner.top + 1,
    inner.width * 0.78,
    (inner.height * 0.16).clamp(1.2, 5.0),
  );
  final topEdge = RRect.fromRectAndRadius(
    topEdgeRect,
    Radius.circular(cornerRadius * 0.6),
  );
  DualBlocksRenderer._blockBevelHighlightPaint.shader = null;
  DualBlocksRenderer._blockBevelHighlightPaint.color = Colors.white.withValues(
    alpha: 0.24,
  );
  canvas.drawRRect(topEdge, DualBlocksRenderer._blockBevelHighlightPaint);

  DualBlocksRenderer._blockBevelBorderPaint.color = Colors.black.withValues(
    alpha: 0.22,
  );
  canvas.drawRRect(innerRRect, DualBlocksRenderer._blockBevelBorderPaint);
}

Color _normalThemeColor({
  required BlockThemeMode mode,
  required int row,
  required int col,
  required double effectTime,
}) {
  assert(effectTime >= 0);
  switch (mode) {
    case BlockThemeMode.solid:
      return GameConstants.normalBlockColor;
    case BlockThemeMode.custom:
      return const Color(0xFFF59E0B);
    case BlockThemeMode.rainbow:
      return _rainbowPaletteColor(row + (col * 3));
  }
}

Color _rainbowPaletteColor(int index) {
  const palette = <Color>[
    Color(0xFF2563EB),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFF97316),
    Color(0xFFFACC15),
    Color(0xFF38BDF8),
    Color(0xFFEF4444),
  ];
  final normalized = index % palette.length;
  return palette[normalized < 0 ? normalized + palette.length : normalized];
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
