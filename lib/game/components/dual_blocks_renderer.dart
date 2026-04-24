import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/game_constants.dart';
import '../models/block_shape.dart';
import '../models/block_theme_mode.dart';
import '../models/cell_state.dart';
import '../models/fate_effect.dart';
import '../models/game_layout.dart';
import '../models/render_frame_data.dart';

part 'dual_blocks_renderer_board.dart';
part 'dual_blocks_renderer_header.dart';
part 'dual_blocks_renderer_tray.dart';
part 'dual_blocks_renderer_effects.dart';

class DualBlocksRenderer {
  static final Paint _boardPaint = Paint()
    ..color = GameConstants.boardBackground;
  static final Paint _gridPaint = Paint()
    ..color = GameConstants.gridLine
    ..strokeWidth = 1;
  static final Paint _trayPaint = Paint()..color = GameConstants.trayBackground;
  static final Paint _headerAngelRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _headerDevilRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _headerDotFillPaint = Paint()..style = PaintingStyle.fill;
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
  static final Paint _lineClearCorePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _lineClearRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;
  static final Paint _lineClearSparkPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _previewLineGlowPaint = Paint()
    ..style = PaintingStyle.fill;
  static final Paint _previewLineBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
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
  static final Paint _blockBevelHighlightPaint = Paint()
    ..style = PaintingStyle.fill;
  static final Paint _blockBevelShadowPaint = Paint()
    ..style = PaintingStyle.fill;
  static final Paint _blockBevelBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static void render({required Canvas canvas, required RenderFrameData frame}) {
    _shapePreviewPaint.color = _cellFallbackPaint.color;
    _shapePreviewAngelPaint.color = _angelCellPaint.color;
    _shapePreviewDevilPaint.color = _devilCellPaint.color;

    _drawBoard(canvas, frame.layout);
    _drawCells(
      canvas,
      frame.layout,
      frame.board,
      themeMode: frame.themeMode,
      effectTime: frame.effectTime,
    );
    if (frame.previewClearRows.isNotEmpty ||
        frame.previewClearCols.isNotEmpty) {
      _drawPreviewClearLines(
        canvas: canvas,
        layout: frame.layout,
        previewRows: frame.previewClearRows,
        previewCols: frame.previewClearCols,
        effectTime: frame.effectTime,
      );
    }
    _drawPlacementFeedback(
      canvas: canvas,
      layout: frame.layout,
      successProgress: frame.placeSuccessProgress,
      failProgress: frame.placeFailProgress,
    );
    if (frame.showClearHighlight) {
      _drawLineClearHighlight(
        canvas: canvas,
        layout: frame.layout,
        clearRows: frame.clearRows,
        clearCols: frame.clearCols,
        effectTime: frame.effectTime,
      );
    }
    if (frame.fateRemovalCells.isNotEmpty &&
        frame.fateRemovalEffectType != null &&
        frame.fateRemovalProgress > 0) {
      _drawFateRemovalOverlay(
        canvas: canvas,
        layout: frame.layout,
        cells: frame.fateRemovalCells,
        effectType: frame.fateRemovalEffectType!,
        progress: frame.fateRemovalProgress.clamp(0, 1).toDouble(),
      );
    }
    _drawDragPreview(
      canvas: canvas,
      layout: frame.layout,
      dragShape: frame.dragShape,
      dragScreenPosition: frame.dragScreenPosition,
      dragCanPlace: frame.dragCanPlace,
    );
    _drawHeader(
      canvas: canvas,
      layout: frame.layout,
      score: frame.score,
      bestScore: frame.bestScore,
      turn: frame.turn,
      storedScore: frame.storedScore,
      comboCount: frame.comboCount,
      angelStack: frame.angelStack,
      devilStack: frame.devilStack,
      effectTime: frame.effectTime,
      scorePulseProgress: frame.scorePulseProgress,
      showThemeMenu: frame.showThemeMenu,
      themeMode: frame.themeMode,
    );
    _drawScorePopup(
      canvas: canvas,
      layout: frame.layout,
      scoreValue: frame.scorePopupValue,
      progress: frame.scorePopupProgress,
    );
    if (frame.showFateBanner &&
        frame.fateType != null &&
        frame.fateReason != null) {
      _drawFateBanner(canvas, frame.layout, frame.fateType!, frame.fateReason!);
    }
    _drawGrid(canvas, frame.layout);
    _drawBottomTray(canvas, frame.layout);
    if (frame.isAlignmentTurn || frame.alignmentChoicePending) {
      _drawAlignmentHeader(canvas, frame.layout);
    }
    _drawTraySlots(
      canvas,
      frame.layout,
      frame.trayBlocks,
      frame.trayFates,
      frame.trayDevilGifts,
      frame.selectedTrayIndex,
      frame.effectTime,
      frame.themeMode,
    );
    if (frame.isGameOver) {
      _drawGameOverOverlay(canvas, frame.layout);
    }
  }
}
