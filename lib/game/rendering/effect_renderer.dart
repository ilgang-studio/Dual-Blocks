part of 'dual_blocks_renderer.dart';

void _drawPlacementFeedback({
  required Canvas canvas,
  required GameLayout layout,
  required double successProgress,
  required double failProgress,
}) {
  if (successProgress > 0) {
    final alpha = successProgress.clamp(0, 1).toDouble() * 0.22;
    DualBlocksRenderer._successOverlayPaint.color = const Color(
      0xFF34D399,
    ).withValues(alpha: alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(12)),
      DualBlocksRenderer._successOverlayPaint,
    );
  }
  if (failProgress > 0) {
    final alpha = failProgress.clamp(0, 1).toDouble() * 0.26;
    DualBlocksRenderer._failOverlayPaint.color = const Color(
      0xFFF87171,
    ).withValues(alpha: alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.boardRect, const Radius.circular(12)),
      DualBlocksRenderer._failOverlayPaint,
    );
  }
}

void _drawLineClearHighlight({
  required Canvas canvas,
  required GameLayout layout,
  required Set<int> clearRows,
  required Set<int> clearCols,
  required double effectTime,
}) {
  final pulse = (math.sin(effectTime * 24.0) + 1) / 2;
  DualBlocksRenderer._lineClearPaint.color = const Color(
    0xFF67E8F9,
  ).withValues(alpha: 0.26 + (pulse * 0.32));
  DualBlocksRenderer._lineClearCorePaint.color = const Color(
    0xFFFFFFFF,
  ).withValues(alpha: 0.18 + (pulse * 0.34));
  DualBlocksRenderer._lineClearRingPaint.color = const Color(
    0xFF22D3EE,
  ).withValues(alpha: 0.45 + (pulse * 0.5));
  DualBlocksRenderer._lineClearSparkPaint.color = const Color(
    0xFFFFFFFF,
  ).withValues(alpha: 0.5 + (pulse * 0.45));

  for (final row in clearRows) {
    final rect = Rect.fromLTWH(
      layout.boardRect.left,
      layout.boardRect.top + (row * layout.cellSize),
      layout.boardRect.width,
      layout.cellSize,
    );
    canvas.drawRect(rect, DualBlocksRenderer._lineClearPaint);
    canvas.drawRect(rect.deflate(2), DualBlocksRenderer._lineClearCorePaint);
    canvas.drawRect(rect.deflate(1), DualBlocksRenderer._lineClearRingPaint);

    final sparkY = rect.center.dy;
    for (var i = 0; i < 8; i++) {
      final sweep = ((effectTime * 420) + (i * 48)) % rect.width;
      canvas.drawCircle(
        Offset(rect.left + sweep, sparkY),
        1.2 + (pulse * 1.2),
        DualBlocksRenderer._lineClearSparkPaint,
      );
    }
  }

  for (final col in clearCols) {
    final rect = Rect.fromLTWH(
      layout.boardRect.left + (col * layout.cellSize),
      layout.boardRect.top,
      layout.cellSize,
      layout.boardRect.height,
    );
    canvas.drawRect(rect, DualBlocksRenderer._lineClearPaint);
    canvas.drawRect(rect.deflate(2), DualBlocksRenderer._lineClearCorePaint);
    canvas.drawRect(rect.deflate(1), DualBlocksRenderer._lineClearRingPaint);

    final sparkX = rect.center.dx;
    for (var i = 0; i < 8; i++) {
      final sweep = ((effectTime * 420) + (i * 48)) % rect.height;
      canvas.drawCircle(
        Offset(sparkX, rect.top + sweep),
        1.2 + (pulse * 1.2),
        DualBlocksRenderer._lineClearSparkPaint,
      );
    }
  }
}

void _drawPreviewClearLines({
  required Canvas canvas,
  required GameLayout layout,
  required Set<int> previewRows,
  required Set<int> previewCols,
  required double effectTime,
}) {
  final pulse = (math.sin(effectTime * 4.0) + 1) / 2;
  final glowAlpha = 0.16 + (pulse * 0.18);
  final borderAlpha = 0.35 + (pulse * 0.35);

  DualBlocksRenderer._previewLineGlowPaint.color = const Color(
    0xFFFFF59D,
  ).withValues(alpha: glowAlpha);
  DualBlocksRenderer._previewLineBorderPaint.color = const Color(
    0xFFFFF176,
  ).withValues(alpha: borderAlpha);

  for (final row in previewRows) {
    final rect = Rect.fromLTWH(
      layout.boardRect.left,
      layout.boardRect.top + (row * layout.cellSize),
      layout.boardRect.width,
      layout.cellSize,
    );
    canvas.drawRect(rect, DualBlocksRenderer._previewLineGlowPaint);
    canvas.drawRect(
      rect.deflate(0.8),
      DualBlocksRenderer._previewLineBorderPaint,
    );
  }

  for (final col in previewCols) {
    final rect = Rect.fromLTWH(
      layout.boardRect.left + (col * layout.cellSize),
      layout.boardRect.top,
      layout.cellSize,
      layout.boardRect.height,
    );
    canvas.drawRect(rect, DualBlocksRenderer._previewLineGlowPaint);
    canvas.drawRect(
      rect.deflate(0.8),
      DualBlocksRenderer._previewLineBorderPaint,
    );
  }
}

void _drawFateRemovalOverlay({
  required Canvas canvas,
  required GameLayout layout,
  required List<math.Point<int>> cells,
  required FateRemovalEffectType effectType,
  required double progress,
}) {
  final pulse = 1 - progress;
  final cellSide = layout.cellSize;
  final isAngel = effectType == FateRemovalEffectType.angelPurge;
  final isDevilBlockBreak = effectType == FateRemovalEffectType.devilBlockBreak;
  final coreColor = isAngel
      ? const Color(0xFFE0F2FE)
      : isDevilBlockBreak
      ? const Color(0xFF16A34A)
      : const Color(0xFF7F1D1D);
  final ringColor = isAngel
      ? const Color(0xFF93C5FD)
      : isDevilBlockBreak
      ? const Color(0xFF22C55E)
      : const Color(0xFFEF4444);

  final ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0 + (pulse * 2.0)
    ..color = ringColor.withValues(alpha: 0.35 + pulse * 0.45);
  final fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = coreColor.withValues(alpha: 0.2 + pulse * 0.45);

  for (final cell in cells) {
    final col = cell.x;
    final row = cell.y;
    if (row < 0 ||
        row >= GameConstants.boardSize ||
        col < 0 ||
        col >= GameConstants.boardSize) {
      continue;
    }
    final rect = Rect.fromLTWH(
      layout.boardRect.left + col * cellSide,
      layout.boardRect.top + row * cellSide,
      cellSide,
      cellSide,
    );
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect.deflate(1), ringPaint);

    if (isAngel) {
      final center = rect.center;
      final sparkleCount = 4;
      for (var i = 0; i < sparkleCount; i++) {
        final angle = (math.pi * 2 / sparkleCount) * i + (pulse * 0.8);
        final radius = (cellSide * 0.18) + (pulse * cellSide * 0.2);
        final sparkleCenter = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
        final star = _buildStarPath(sparkleCenter, 1.8 + (pulse * 2.8));
        DualBlocksRenderer._angelSparkPaint.color = const Color(
          0xFFFFFFFF,
        ).withValues(alpha: 0.35 + (pulse * 0.55));
        canvas.drawPath(star, DualBlocksRenderer._angelSparkPaint);
      }
      continue;
    }

    if (isDevilBlockBreak) {
      for (var i = 0; i < 4; i++) {
        final x = rect.left + (cellSide * (0.2 + (i * 0.2)));
        final fall = (pulse + (i * 0.08)) % 1.0;
        final y = rect.top + (cellSide * fall);
        DualBlocksRenderer._devilGreenDotPaint.color = const Color(
          0xFF22C55E,
        ).withValues(alpha: 0.2 + ((1 - fall) * 0.7));
        canvas.drawCircle(
          Offset(x, y),
          1.2 + (pulse * 1.6),
          DualBlocksRenderer._devilGreenDotPaint,
        );
      }
      continue;
    }

    for (var i = 0; i < 4; i++) {
      final x = rect.left + (cellSide * (0.18 + (i * 0.2)));
      final rise = (pulse + (i * 0.09)) % 1.0;
      final y = rect.bottom - (cellSide * rise);
      final useRed = i.isEven;
      final paint = useRed
          ? DualBlocksRenderer._devilRedDotPaint
          : DualBlocksRenderer._devilBlackDotPaint;
      paint.color = (useRed ? const Color(0xFFEF4444) : const Color(0xFF111827))
          .withValues(alpha: 0.18 + ((1 - rise) * 0.8));
      canvas.drawCircle(Offset(x, y), 1.3 + (pulse * 1.4), paint);
    }
  }
}

void _drawGameOverOverlay(Canvas canvas, GameLayout layout, String language) {
  canvas.drawRect(layout.boardRect, DualBlocksRenderer._gameOverOverlayPaint);
  final textDirection = GameLocalization.isRtl(language)
      ? TextDirection.rtl
      : TextDirection.ltr;

  final titlePainter = TextPainter(
    text: TextSpan(
      text: GameLocalization.gameOverTitle(language),
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    textDirection: textDirection,
  )..layout();

  final hintPainter = TextPainter(
    text: TextSpan(
      text: GameLocalization.gameOverHint(language),
      style: TextStyle(
        color: Color(0xFFD1D5DB),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    textDirection: textDirection,
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
