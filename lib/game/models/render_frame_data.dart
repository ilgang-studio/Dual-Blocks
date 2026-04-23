import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'block_shape.dart';
import 'block_theme_mode.dart';
import 'cell_state.dart';
import 'fate_effect.dart';
import 'game_layout.dart';

class RenderFrameData {
  const RenderFrameData({
    required this.layout,
    required this.score,
    required this.bestScore,
    required this.turn,
    required this.isGameOver,
    required this.board,
    required this.trayBlocks,
    required this.trayFates,
    required this.trayDevilGifts,
    required this.selectedTrayIndex,
    required this.isAlignmentTurn,
    required this.alignmentChoicePending,
    required this.effectTime,
    required this.themeMode,
    required this.showThemeMenu,
    required this.dragShape,
    required this.dragScreenPosition,
    required this.dragCanPlace,
    required this.previewClearRows,
    required this.previewClearCols,
    required this.clearRows,
    required this.clearCols,
    required this.showClearHighlight,
    required this.fateRemovalCells,
    required this.fateRemovalEffectType,
    required this.fateRemovalProgress,
    required this.fateType,
    required this.fateReason,
    required this.showFateBanner,
    required this.angelStack,
    required this.devilStack,
    required this.storedScore,
    required this.comboCount,
    required this.scorePopupValue,
    required this.scorePopupProgress,
    required this.scorePulseProgress,
    required this.placeSuccessProgress,
    required this.placeFailProgress,
  });

  final GameLayout layout;
  final int score;
  final int bestScore;
  final int turn;
  final bool isGameOver;
  final List<List<CellState>> board;
  final List<BlockShape?> trayBlocks;
  final List<FateType?> trayFates;
  final List<DevilGiftType?> trayDevilGifts;
  final int? selectedTrayIndex;
  final bool isAlignmentTurn;
  final bool alignmentChoicePending;
  final double effectTime;
  final BlockThemeMode themeMode;
  final bool showThemeMenu;
  final BlockShape? dragShape;
  final Offset? dragScreenPosition;
  final bool dragCanPlace;
  final Set<int> previewClearRows;
  final Set<int> previewClearCols;
  final Set<int> clearRows;
  final Set<int> clearCols;
  final bool showClearHighlight;
  final List<math.Point<int>> fateRemovalCells;
  final FateRemovalEffectType? fateRemovalEffectType;
  final double fateRemovalProgress;
  final FateType? fateType;
  final String? fateReason;
  final bool showFateBanner;
  final int angelStack;
  final int devilStack;
  final int storedScore;
  final int comboCount;
  final int scorePopupValue;
  final double scorePopupProgress;
  final double scorePulseProgress;
  final double placeSuccessProgress;
  final double placeFailProgress;
}
