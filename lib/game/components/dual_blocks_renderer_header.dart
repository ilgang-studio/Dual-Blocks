part of 'dual_blocks_renderer.dart';

void _drawHeader({
  required Canvas canvas,
  required GameLayout layout,
  required int score,
  required int bestScore,
  required int turn,
  required int storedScore,
  required int comboCount,
  required int angelStack,
  required int devilStack,
  required double effectTime,
  required bool showThemeMenu,
  required BlockThemeMode themeMode,
}) {
  _drawScorePanelBackground(canvas, layout);

  final neonPulse = (math.sin(effectTime * 8.5) + 1) / 2;
  final isComboActive = comboCount > 0;
  final scoreColor = isComboActive
      ? Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFF67E8F9),
          neonPulse * 0.42,
        )!
      : const Color(0xFFE2E8F0);
  final glowAlpha = isComboActive ? 0.45 + (neonPulse * 0.45) : 0.0;

  final topLabelPainter = TextPainter(
    text: TextSpan(
      text: 'TOP $bestScore',
      style: const TextStyle(
        color: Color(0xFFFDE68A),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  topLabelPainter.paint(
    canvas,
    Offset(layout.scoreRect.left + 10, layout.scoreRect.top + 14),
  );

  final centerTitlePainter = TextPainter(
    text: const TextSpan(
      text: '현재 점수',
      style: TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  centerTitlePainter.paint(
    canvas,
    Offset(
      layout.scoreRect.center.dx - (centerTitlePainter.width / 2),
      layout.scoreRect.top + 8,
    ),
  );

  final scorePainter = TextPainter(
    text: TextSpan(
      text: '$score',
      style: TextStyle(
        color: scoreColor,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        shadows: [
          Shadow(
            color: const Color(0xFF22D3EE).withValues(alpha: glowAlpha),
            blurRadius: 10 + (neonPulse * 7),
          ),
          Shadow(
            color: const Color(0xFFFFFFFF).withValues(alpha: glowAlpha * 0.5),
            blurRadius: 4 + (neonPulse * 4),
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  scorePainter.paint(
    canvas,
    Offset(
      layout.scoreRect.center.dx - (scorePainter.width / 2),
      layout.scoreRect.top + 20,
    ),
  );

  final metaPainter = TextPainter(
    text: TextSpan(
      text: 'TURN $turn   |   STORED $storedScore',
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  metaPainter.paint(
    canvas,
    Offset(
      layout.scoreRect.center.dx - (metaPainter.width / 2),
      layout.scoreRect.bottom - metaPainter.height - 4,
    ),
  );

  final comboPainter = TextPainter(
    text: TextSpan(
      text: isComboActive ? 'COMBO x$comboCount' : '',
      style: TextStyle(
        color: const Color(
          0xFF06B6D4,
        ).withValues(alpha: 0.6 + (neonPulse * 0.35)),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  if (isComboActive) {
    comboPainter.paint(
      canvas,
      Offset(
        layout.scoreRect.center.dx - (comboPainter.width / 2),
        layout.scoreRect.top + 45,
      ),
    );
  }

  _drawHeaderStackDots(
    canvas: canvas,
    layout: layout,
    stack: angelStack,
    isAngel: true,
    effectTime: effectTime,
  );
  _drawHeaderStackDots(
    canvas: canvas,
    layout: layout,
    stack: devilStack,
    isAngel: false,
    effectTime: effectTime,
  );

  _drawSettingsButton(canvas: canvas, layout: layout, isOpen: showThemeMenu);
  if (showThemeMenu) {
    _drawThemeMenu(canvas: canvas, layout: layout, selectedMode: themeMode);
  }
}

void _drawHeaderStackDots({
  required Canvas canvas,
  required GameLayout layout,
  required int stack,
  required bool isAngel,
  required double effectTime,
}) {
  final safeStack = stack.clamp(0, 3);
  const spacing = 19.0;
  final baseY = layout.scoreRect.top + 54;
  final startX = isAngel
      ? layout.scoreRect.left + 20
      : layout.scoreRect.right - 20 - (spacing * 2);
  final ringColor = isAngel ? const Color(0xFF67E8F9) : const Color(0xFFB91C1C);
  final fillColor = isAngel ? const Color(0xFF22D3EE) : const Color(0xFFEF4444);
  final pulse = (math.sin(effectTime * 7.0) + 1) / 2;
  final radius = 6.0;

  final ringPaint = isAngel
      ? DualBlocksRenderer._headerAngelRingPaint
      : DualBlocksRenderer._headerDevilRingPaint;
  ringPaint.color = ringColor.withValues(alpha: 0.95);

  for (var i = 0; i < 3; i++) {
    final center = Offset(startX + (i * spacing), baseY);
    canvas.drawCircle(center, radius, ringPaint);
    if (i < safeStack) {
      DualBlocksRenderer._headerDotFillPaint.color = fillColor.withValues(
        alpha: 0.45 + (pulse * 0.4),
      );
      canvas.drawCircle(
        center,
        radius - 2,
        DualBlocksRenderer._headerDotFillPaint,
      );
    }
  }
}

void _drawScorePanelBackground(Canvas canvas, GameLayout layout) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      layout.scoreRect,
      const Radius.circular(GameConstants.cornerRadius),
    ),
    DualBlocksRenderer._trayPaint,
  );
}

void _drawSettingsButton({
  required Canvas canvas,
  required GameLayout layout,
  required bool isOpen,
}) {
  final rect = layout.settingsButtonRect();
  final paint = Paint()
    ..color = isOpen ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
  final border = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xFF334155);

  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(7)),
    paint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(7)),
    border,
  );

  _drawGearIcon(canvas, rect.center, const Color(0xFFE2E8F0));
}

void _drawThemeMenu({
  required Canvas canvas,
  required GameLayout layout,
  required BlockThemeMode selectedMode,
}) {
  final menu = layout.themeMenuRect();
  final panelPaint = Paint()..color = const Color(0xFF0F172A);
  final panelBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xFF334155);
  canvas.drawRRect(
    RRect.fromRectAndRadius(menu, const Radius.circular(8)),
    panelPaint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(menu, const Radius.circular(8)),
    panelBorder,
  );

  final options = BlockThemeMode.values;
  for (var i = 0; i < options.length; i++) {
    final rect = layout.themeOptionRect(i);
    final option = options[i];
    final isSelected = option == selectedMode;
    final bg = Paint()
      ..color = isSelected ? const Color(0xFF1D4ED8) : const Color(0x00000000);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      bg,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: option.label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 10);

    textPainter.paint(
      canvas,
      Offset(rect.left + 8, rect.center.dy - (textPainter.height / 2)),
    );
  }
}

void _drawGearIcon(Canvas canvas, Offset center, Color color) {
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..color = color;

  const outer = 6.0;
  for (var i = 0; i < 8; i++) {
    final angle = (math.pi / 4) * i;
    final start = Offset(
      center.dx + math.cos(angle) * (outer + 1.6),
      center.dy + math.sin(angle) * (outer + 1.6),
    );
    final end = Offset(
      center.dx + math.cos(angle) * (outer + 3.8),
      center.dy + math.sin(angle) * (outer + 3.8),
    );
    canvas.drawLine(start, end, stroke);
  }

  canvas.drawCircle(center, outer, stroke);
  canvas.drawCircle(center, 2.3, stroke);
}

void _drawScorePopup({
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

void _drawFateBanner(
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
      ? DualBlocksRenderer._angelBadgePaint
      : DualBlocksRenderer._devilBadgePaint;
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
