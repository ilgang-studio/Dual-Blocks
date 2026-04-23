import 'package:flutter/material.dart';

enum AngelEffectMode { rescueCleanup, scoreShield, handRefine }

class GameConstants {
  static const int boardSize = 8;

  static const double horizontalPadding = 16;
  static const double topPadding = 100;
  static const double trayHeight = 120;
  static const double sectionGap = 16;
  static const double scoreHeight = 72;
  static const double scoreGapFromBoard = 86;
  static const double cornerRadius = 12;
  static const double outerBottomPadding = 16;
  static const int traySlotCount = 3;
  static const double trayInnerPadding = 12;
  static const double traySlotGap = 12;

  static const Color boardBackground = Color(0xFF1F2937);
  static const Color gridLine = Color(0xFF374151);
  static const Color trayBackground = Color(0xFF111827);
  static const Color scoreBackground = Color(0xFF111827);
  static const Color traySlotBackground = Color(0xFF1F2937);
  static const Color normalBlockColor = Color(0xFF94A3B8);
  static const Color angelBlockColor = Color(0xFF93C5FD);
  static const Color devilBlockColor = Color(0xFF7F1D1D);
  static const Color traySlotSelected = Color(0xFF60A5FA);
  static const Color lineClearHighlight = Color(0xFF22D3EE);
  static const Color angelEffect = Color(0xFF34D399);
  static const Color devilEffect = Color(0xFFF87171);

  static const int lineClearPointPerCell = 2;
  static const int lineClearBasePoint = 10;
  static const double lineClearMultiLineBonusMultiplier = 2.0;
  static const double lineClearHighlightSeconds = 0.18;
  static const double fateRemovalEffectSeconds = 0.18;
  static const double scorePopupSeconds = 0.45;
  static const double placementSuccessSeconds = 0.14;
  static const double placementFailSeconds = 0.16;
  static const int fateTriggerStack = 3;
  static const double angelStoreRatio = 0.5;
  static const AngelEffectMode angelEffectMode = AngelEffectMode.rescueCleanup;
  static const double angelNextClearScoreMultiplier = 1.5;
  static const double angelEasyWeightMultiplier = 1.35;
  static const double angelHardWeightMultiplier = 0.65;
  static const double devilScorePenaltyRatio = 0.1;
  static const double fateBannerSeconds = 1.4;
}
