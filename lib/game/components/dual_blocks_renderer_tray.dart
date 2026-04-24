part of 'dual_blocks_renderer.dart';

void _drawBottomTray(Canvas canvas, GameLayout layout) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      layout.bottomTrayRect,
      const Radius.circular(GameConstants.cornerRadius),
    ),
    DualBlocksRenderer._trayPaint,
  );
}

void _drawTraySlots(
  Canvas canvas,
  GameLayout layout,
  List<BlockShape?> trayBlocks,
  List<int?> trayBlockColorIndices,
  List<FateType?> trayFates,
  List<DevilGiftType?> trayDevilGifts,
  int? selectedTrayIndex,
  double effectTime,
  BlockThemeMode themeMode,
  Color customThemeColor,
) {
  final slotRects = layout.traySlotRects();
  for (var i = 0; i < slotRects.length; i++) {
    final slotRect = slotRects[i];
    final slotFate = i < trayFates.length ? trayFates[i] : null;
    canvas.drawRRect(
      RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
      DualBlocksRenderer._slotPaint,
    );
    if (selectedTrayIndex == i) {
      final glowRect = slotRect.inflate(6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, const Radius.circular(14)),
        DualBlocksRenderer._slotGlowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(slotRect, const Radius.circular(10)),
        DualBlocksRenderer._slotSelectedPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(slotRect.deflate(1), const Radius.circular(10)),
        DualBlocksRenderer._slotSelectedBorderPaint,
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
        blockColorIndex: i < trayBlockColorIndices.length
            ? trayBlockColorIndices[i]
            : null,
        fate: slotFate,
        scale: selectedTrayIndex == i ? 1.08 : 1.0,
        themeMode: themeMode,
        customThemeColor: customThemeColor,
        effectTime: effectTime,
        slotIndex: i,
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

void _drawAngelSparkles(
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

    DualBlocksRenderer._angelSparkPaint.color = const Color(
      0xFFF8FAFC,
    ).withValues(alpha: alpha);
    final path = _buildStarPath(Offset(px, py), radius);
    canvas.drawPath(path, DualBlocksRenderer._angelSparkPaint);
  }
}

void _drawDevilGreedDots(
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
        effectRect.bottom - 3 - (phase * math.max(1.0, effectRect.height - 6));
    final size = 1.6 + ((i % 3) * 0.7);
    final alpha = 0.2 + (1 - phase) * 0.8;

    final paint = i.isEven
        ? DualBlocksRenderer._devilRedDotPaint
        : DualBlocksRenderer._devilBlackDotPaint;
    paint.color = (i.isEven ? const Color(0xFFEF4444) : const Color(0xFF111827))
        .withValues(alpha: alpha);
    canvas.drawCircle(Offset(baseX, y), size, paint);
  }
}

void _drawDevilDestructionDots(
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

    DualBlocksRenderer._devilGreenDotPaint.color = const Color(
      0xFF22C55E,
    ).withValues(alpha: alpha);
    canvas.drawCircle(
      Offset(baseX, y),
      size,
      DualBlocksRenderer._devilGreenDotPaint,
    );
  }
}

Path _buildStarPath(Offset center, double radius) {
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

void _drawAlignmentHeader(Canvas canvas, GameLayout layout) {
  // Intentionally hidden: alignment hint text removed by design request.
}

void _drawShapePreview(
  Canvas canvas,
  Rect slotRect,
  BlockShape shape, {
  int? blockColorIndex,
  FateType? fate,
  double scale = 1.0,
  required BlockThemeMode themeMode,
  required Color customThemeColor,
  required double effectTime,
  required int slotIndex,
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
    final themedColor =
        themeMode == BlockThemeMode.rainbow && blockColorIndex != null
        ? _rainbowPaletteColor(blockColorIndex)
        : _normalThemeColor(
            mode: themeMode,
            row: point.y + slotIndex,
            col: point.x + slotIndex,
            customThemeColor: customThemeColor,
            effectTime: effectTime,
          );
    DualBlocksRenderer._shapePreviewPaint.color = themedColor;
    final paint = fate == FateType.angel
        ? DualBlocksRenderer._shapePreviewAngelPaint
        : fate == FateType.devil
        ? DualBlocksRenderer._shapePreviewDevilPaint
        : DualBlocksRenderer._shapePreviewPaint;
    _drawBeveledBlockTile(
      canvas: canvas,
      rect: Rect.fromLTWH(left, top, cellSize - 2, cellSize - 2),
      color: paint.color,
      cornerRadius: 3,
    );
  }
}

Rect _shapePreviewBounds(Rect slotRect, BlockShape shape) {
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
