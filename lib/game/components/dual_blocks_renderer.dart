import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../models/block_shape.dart';
import '../models/cell_state.dart';
import '../models/fate_effect.dart';
import '../models/game_layout.dart';

class DualBlocksRenderer {
  static final Paint _boardPaint = Paint()
    ..color = GameConstants.boardBackground;
  static final Paint _gridPaint = Paint()
    ..color = GameConstants.gridLine
    ..strokeWidth = 1;
  static final Paint _trayPaint = Paint()..color = GameConstants.trayBackground;
  static final Paint _scorePaint = Paint()
    ..color = GameConstants.scoreBackground;
  static final Paint _cellFallbackPaint = Paint()
    ..color = GameConstants.normalBlockColor;
  static final Paint _angelCellPaint = Paint()
    ..color = GameConstants.angelBlockColor;
  static final Paint _devilCellPaint = Paint()
    ..color = GameConstants.devilBlockColor;
  static final Paint _slotPaint = Paint()
    ..color = GameConstants.traySlotBackground;
  static final Paint _slotSelectedPaint = Paint()
    ..color = GameConstants.traySlotSelected.withValues(alpha: 0.35);
  static final Paint _slotSelectedBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = const Color(0xFFE2E8F0);
  static final Paint _slotGlowPaint = Paint()
    ..color = const Color(0x668EC5FF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  static final Paint _shapePreviewPaint = Paint()..color = Colors.blue;
  static final Paint _shapePreviewAngelPaint = Paint()
    ..color = const Color(0xFF93C5FD);
  static final Paint _shapePreviewDevilPaint = Paint()
    ..color = const Color(0xFF7F1D1D);
  static final Paint _dragPreviewFillPaint = Paint()
    ..color = const Color(0x99FFFFFF)
    ..style = PaintingStyle.fill;
  static final Paint _dragPreviewBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2;
  static final Paint _lineClearPaint = Paint()
    ..color = GameConstants.lineClearHighlight.withValues(alpha: 0.38);
  static final Paint _successOverlayPaint = Paint()
    ..color = const Color(0xFF34D399).withValues(alpha: 0.0);
  static final Paint _failOverlayPaint = Paint()
    ..color = const Color(0xFFF87171).withValues(alpha: 0.0);
  static final Paint _gameOverOverlayPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.45);
  static final Paint _angelBadgePaint = Paint()
    ..color = GameConstants.angelEffect.withValues(alpha: 0.25);
  static final Paint _devilBadgePaint = Paint()
    ..color = GameConstants.devilEffect.withValues(alpha: 0.25);
  static final Paint _angelSparkPaint = Paint()
    ..color = const Color(0xFFF8FAFC)
    ..style = PaintingStyle.fill;
  static final Paint _devilRedDotPaint = Paint()
    ..color = const Color(0xFFEF4444)
    ..style = PaintingStyle.fill;
  static final Paint _devilBlackDotPaint = Paint()
    ..color = const Color(0xFF111827)
    ..style = PaintingStyle.fill;
  static final Paint _devilGreenDotPaint = Paint()
    ..color = const Color(0xFF22C55E)
    ..style = PaintingStyle.fill;

  static void render({
    required Canvas canvas,
    required GameLayout layout,
    required int score,
    required int turn,
    required bool isGameOver,
    required List<List<CellState>> board,
    required List<BlockShape?> trayBlocks,
    required List<FateType?> trayFates,
    required List<DevilGiftType?> trayDevilGifts,
    required int? selectedTrayIndex,
    required bool isAlignmentTurn,
    required bool alignmentChoicePending,
    required double effectTime,
    required BlockShape? dragShape,
    required Offset? dragScreenPosition,
    required bool dragCanPlace,
    required Set<int> clearRows,
    required Set<int> clearCols,
    required bool showClearHighlight,
    required FateType? fateType,
    required String? fateReason,
    required bool showFateBanner,
    required int angelStack,
    required int devilStack,
    required int storedScore,
    required int scorePopupValue,
    required double scorePopupProgress,
    required double placeSuccessProgress,
    required double placeFailProgress,
  }) {
    // Keep preview colors in sync with actual placed-cell colors even after hot reload.
    _shapePreviewPaint.color = _cellFallbackPaint.color;
    _shapePreviewAngelPaint.color = _angelCellPaint.color;
    _shapePreviewDevilPaint.color = _devilCellPaint.color;

    _drawBoard(canvas, layout);
    _drawCells(canvas, layout, board);
    _drawPlacementFeedback(
      canvas: canvas,
      layout: layout,
      successProgress: placeSuccessProgress,
      failProgress: placeFailProgress,
    );
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
    _drawTurn(canvas, layout, turn);
    _drawStoredScore(canvas, layout, storedScore);
    _drawScorePopup(
      canvas: canvas,
      layout: layout,
      scoreValue: scorePopupValue,
      progress: scorePopupProgress,
    );
    _drawFateSelectors(
      canvas: canvas,
      layout: layout,
      angelStack: angelStack,
      devilStack: devilStack,
    );
    if (showFateBanner && fateType != null && fateReason != null) {
      _drawFateBanner(canvas, layout, fateType, fateReason);
    }
    _drawGrid(canvas, layout);
    _drawBottomTray(canvas, layout);
    if (isAlignmentTurn || alignmentChoicePending) {
      _drawAlignmentHeader(canvas, layout);
    }
    _drawTraySlots(
      canvas,
      layout,
      trayBlocks,
      trayFates,
      trayDevilGifts,
      selectedTrayIndex,
      effectTime,
    );
    if (isGameOver) {
      _drawGameOverOverlay(canvas, layout);
    }
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

          canvas.drawRect(rect, _cellFallbackPaint);
        }
        if (board[row][col] == CellState.angelFilled) {
          final rect = Rect.fromLTWH(
            layout.boardRect.left + col * layout.cellSize,
            layout.boardRect.top + row * layout.cellSize,
            layout.cellSize,
            layout.cellSize,
          );
          canvas.drawRect(rect, _angelCellPaint);
        }
        if (board[row][col] == CellState.devilFilled) {
          final rect = Rect.fromLTWH(
            layout.boardRect.left + col * layout.cellSize,
            layout.boardRect.top + row * layout.cellSize,
            layout.cellSize,
            layout.cellSize,
          );
          canvas.drawRect(rect, _devilCellPaint);
        }
      }
    }
  }

  static void _drawScore(Canvas canvas, GameLayout layout, int score) {
    _drawScorePanelBackground(canvas, layout);

    final scorePainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    scorePainter.paint(
      canvas,
      Offset(layout.scoreRect.left + 14, layout.scoreRect.top + 8),
    );
  }

  static void _drawTurn(Canvas canvas, GameLayout layout, int turn) {
    final turnPainter = TextPainter(
      text: TextSpan(
        text: 'Turn: $turn',
        style: const TextStyle(
          color: Color(0xFFBFDBFE),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    turnPainter.paint(
      canvas,
      Offset(layout.scoreRect.left + 14, layout.scoreRect.top + 28),
    );
  }

  static void _drawStoredScore(
    Canvas canvas,
    GameLayout layout,
    int storedScore,
  ) {
    final chargePainter = TextPainter(
      text: TextSpan(
        text: 'Stored: $storedScore',
        style: const TextStyle(
          color: Color(0xFFFDE68A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    chargePainter.paint(
      canvas,
      Offset(
        layout.scoreRect.right - chargePainter.width - 12,
        layout.scoreRect.top + 8,
      ),
    );
  }

  static void _drawFateSelectors({
    required Canvas canvas,
    required GameLayout layout,
    required int angelStack,
    required int devilStack,
  }) {
    final angelRect = layout.angelChoiceRect();
    final devilRect = layout.devilChoiceRect();

    canvas.drawRRect(
      RRect.fromRectAndRadius(angelRect, const Radius.circular(8)),
      _angelBadgePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(devilRect, const Radius.circular(8)),
      _devilBadgePaint,
    );

    _drawFateSelectorLabel(
      canvas: canvas,
      rect: angelRect,
      label: 'Angel',
      color: const Color(0xFFD1FAE5),
      stack: angelStack,
    );
    _drawFateSelectorLabel(
      canvas: canvas,
      rect: devilRect,
      label: 'Devil',
      color: const Color(0xFFFEE2E2),
      stack: devilStack,
    );
  }

  static void _drawFateSelectorLabel({
    required Canvas canvas,
    required Rect rect,
    required String label,
    required Color color,
    required int stack,
  }) {
    final dots = _stackDots(stack);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label $dots',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.width - 6);

    textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 3));
  }

  static String _stackDots(int stack) {
    final safe = stack.clamp(0, 3);
    return '${'●' * safe}${'○' * (3 - safe)}';
  }

  static void _drawScorePanelBackground(Canvas canvas, GameLayout layout) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.scoreRect,
        const Radius.circular(GameConstants.cornerRadius),
      ),
      _scorePaint,
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
    List<FateType?> trayFates,
    List<DevilGiftType?> trayDevilGifts,
    int? selectedTrayIndex,
    double effectTime,
  ) {
    final slotRects = layout.traySlotRects();
    for (var i = 0; i < slotRects.length; i++) {
      final slotRect = slotRects[i];
      final slotFate = i < trayFates.length ? trayFates[i] : null;
      final slotPaint = slotFate == FateType.angel
          ? _angelBadgePaint
          : slotFate == FateType.devil
          ? _devilBadgePaint
          : _slotPaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
        slotPaint,
      );
      if (selectedTrayIndex == i) {
        final glowRect = slotRect.inflate(6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(14)),
          _slotGlowPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
          _slotSelectedPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            slotRect.deflate(1),
            const Radius.circular(10),
          ),
          _slotSelectedBorderPaint,
        );
      }

      final shape = i < trayBlocks.length ? trayBlocks[i] : null;
      final effectRect = shape == null
          ? slotRect.deflate(8)
          : _shapePreviewBounds(slotRect, shape);
      if (shape != null) {
        _drawShapePreview(
          canvas,
          slotRect,
          shape,
          fate: slotFate,
          scale: selectedTrayIndex == i ? 1.08 : 1.0,
        );
      }

      if (slotFate == FateType.angel) {
        _drawAngelSparkles(canvas, effectRect, effectTime, i);
      } else if (slotFate == FateType.devil) {
        final devilGift = i < trayDevilGifts.length ? trayDevilGifts[i] : null;
        if (devilGift == DevilGiftType.destructionAid) {
          _drawDevilDestructionDots(canvas, effectRect, effectTime, i);
        } else {
          _drawDevilGreedDots(canvas, effectRect, effectTime, i);
        }
      }
    }
  }

  static void _drawAngelSparkles(
    Canvas canvas,
    Rect effectRect,
    double effectTime,
    int slotIndex,
  ) {
    for (var i = 0; i < 8; i++) {
      final seed = (slotIndex * 37 + i * 11).toDouble();
      final px =
          effectRect.left +
          3 +
          ((seed * 17) % (math.max(1.0, effectRect.width - 6)));
      final py =
          effectRect.top +
          3 +
          ((seed * 29) % (math.max(1.0, effectRect.height - 6)));
      final blink = (math.sin(effectTime * 4.8 + seed) + 1) / 2;
      final radius = 2.4 + blink * 2.2;
      final alpha = 0.25 + blink * 0.75;

      _angelSparkPaint.color = const Color(0xFFF8FAFC).withValues(alpha: alpha);
      final path = _buildStarPath(Offset(px, py), radius);
      canvas.drawPath(path, _angelSparkPaint);
    }
  }

  static void _drawDevilGreedDots(
    Canvas canvas,
    Rect effectRect,
    double effectTime,
    int slotIndex,
  ) {
    for (var i = 0; i < 12; i++) {
      final seed = (slotIndex * 41 + i * 13).toDouble();
      final baseX =
          effectRect.left +
          3 +
          ((seed * 19) % (math.max(1.0, effectRect.width - 6)));
      final phase = (effectTime * 0.8 + (i * 0.07)) % 1.0;
      final y =
          effectRect.bottom -
          3 -
          (phase * math.max(1.0, effectRect.height - 6));
      final size = 1.6 + ((i % 3) * 0.7);
      final alpha = 0.2 + (1 - phase) * 0.8;

      final paint = i.isEven ? _devilRedDotPaint : _devilBlackDotPaint;
      paint.color =
          (i.isEven ? const Color(0xFFEF4444) : const Color(0xFF111827))
              .withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, y), size, paint);
    }
  }

  static void _drawDevilDestructionDots(
    Canvas canvas,
    Rect effectRect,
    double effectTime,
    int slotIndex,
  ) {
    for (var i = 0; i < 12; i++) {
      final seed = (slotIndex * 53 + i * 7).toDouble();
      final baseX =
          effectRect.left +
          3 +
          ((seed * 23) % (math.max(1.0, effectRect.width - 6)));
      final phase = (effectTime * 0.75 + (i * 0.09)) % 1.0;
      final y =
          effectRect.top + 3 + (phase * math.max(1.0, effectRect.height - 6));
      final size = 1.8 + ((i % 3) * 0.8);
      final alpha = 0.25 + (1 - phase) * 0.7;

      _devilGreenDotPaint.color = const Color(
        0xFF22C55E,
      ).withValues(alpha: alpha);
      canvas.drawCircle(Offset(baseX, y), size, _devilGreenDotPaint);
    }
  }

  static Path _buildStarPath(Offset center, double radius) {
    final path = Path();
    final inner = radius * 0.45;

    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + (math.pi / 5) * i;
      final r = i.isEven ? radius : inner;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static void _drawAlignmentHeader(Canvas canvas, GameLayout layout) {
    final painter = TextPainter(
      text: const TextSpan(
        text: 'ALIGNMENT TURN: Choose 1 (others discarded)',
        style: TextStyle(
          color: Color(0xFFFDE68A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: layout.bottomTrayRect.width);

    painter.paint(
      canvas,
      Offset(layout.bottomTrayRect.left + 8, layout.bottomTrayRect.top - 16),
    );
  }

  static void _drawShapePreview(
    Canvas canvas,
    Rect slotRect,
    BlockShape shape, {
    FateType? fate,
    double scale = 1.0,
  }) {
    var previewBounds = _shapePreviewBounds(slotRect, shape);
    if (scale != 1.0) {
      final scaledWidth = previewBounds.width * scale;
      final scaledHeight = previewBounds.height * scale;
      previewBounds = Rect.fromCenter(
        center: previewBounds.center,
        width: scaledWidth,
        height: scaledHeight,
      );
    }
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

    final cellSize = ((previewBounds.width) / ((maxX - minX) + 1));
    final originX = previewBounds.left;
    final originY = previewBounds.top;

    for (final point in points) {
      final left = originX + ((point.x - minX) * cellSize);
      final top = originY + ((point.y - minY) * cellSize);
      final paint = fate == FateType.angel
          ? _shapePreviewAngelPaint
          : fate == FateType.devil
          ? _shapePreviewDevilPaint
          : _shapePreviewPaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellSize - 2, cellSize - 2),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  static Rect _shapePreviewBounds(Rect slotRect, BlockShape shape) {
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
    return Rect.fromLTWH(originX, originY, width, height);
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

    final borderColor = dragCanPlace
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    _dragPreviewBorderPaint.color = borderColor;
    _dragPreviewFillPaint.color = borderColor.withValues(alpha: 0.28);
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
      canvas.drawRect(rect, _dragPreviewFillPaint);
      canvas.drawRect(rect.deflate(1), _dragPreviewBorderPaint);
    }
  }

  static void _drawPlacementFeedback({
    required Canvas canvas,
    required GameLayout layout,
    required double successProgress,
    required double failProgress,
  }) {
    if (successProgress > 0) {
      final alpha = successProgress.clamp(0, 1).toDouble() * 0.22;
      _successOverlayPaint.color = const Color(
        0xFF34D399,
      ).withValues(alpha: alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(12)),
        _successOverlayPaint,
      );
    }
    if (failProgress > 0) {
      final alpha = failProgress.clamp(0, 1).toDouble() * 0.26;
      _failOverlayPaint.color = const Color(
        0xFFF87171,
      ).withValues(alpha: alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(12)),
        _failOverlayPaint,
      );
    }
  }

  static void _drawScorePopup({
    required Canvas canvas,
    required GameLayout layout,
    required int scoreValue,
    required double progress,
  }) {
    if (progress <= 0 || scoreValue <= 0) return;
    final yLift = (1 - progress) * 26;
    final alpha = progress.clamp(0, 1).toDouble();

    final painter = TextPainter(
      text: TextSpan(
        text: '+$scoreValue',
        style: TextStyle(
          color: const Color(0xFFFDE68A).withValues(alpha: alpha),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        layout.boardRect.center.dx - (painter.width / 2),
        layout.boardRect.top - 18 - yLift,
      ),
    );
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

  static void _drawGameOverOverlay(Canvas canvas, GameLayout layout) {
    canvas.drawRect(layout.boardRect, _gameOverOverlayPaint);

    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'GAME OVER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final hintPainter = TextPainter(
      text: const TextSpan(
        text: 'Tap anywhere to restart',
        style: TextStyle(
          color: Color(0xFFD1D5DB),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    titlePainter.paint(
      canvas,
      Offset(
        layout.boardRect.center.dx - (titlePainter.width / 2),
        layout.boardRect.center.dy - titlePainter.height,
      ),
    );

    hintPainter.paint(
      canvas,
      Offset(
        layout.boardRect.center.dx - (hintPainter.width / 2),
        layout.boardRect.center.dy + 8,
      ),
    );
  }

  static void _drawFateBanner(
    Canvas canvas,
    GameLayout layout,
    FateType type,
    String reason,
  ) {
    final badgeRect = Rect.fromLTWH(
      layout.scoreRect.right - 190,
      layout.scoreRect.top + 24,
      178,
      20,
    );
    final badgePaint = type == FateType.angel
        ? _angelBadgePaint
        : _devilBadgePaint;
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)),
      badgePaint,
    );

    final title = type == FateType.angel ? 'ANGEL' : 'DEVIL';
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$title: $reason',
        style: TextStyle(
          color: type == FateType.angel
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFEE2E2),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: badgeRect.width - 10);

    textPainter.paint(canvas, Offset(badgeRect.left + 5, badgeRect.top + 3));
  }
}
