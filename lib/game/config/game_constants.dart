import 'package:flutter/material.dart';

class GameConstants {
  static const int boardSize = 8;

  static const double horizontalPadding = 16;
  static const double topPadding = 100;
  static const double trayHeight = 120;
  static const double sectionGap = 16;
  static const double scoreHeight = 50;
  static const double scoreGapFromBoard = 70;
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
  static const Color traySlotSelected = Color(0xFF60A5FA);
  static const Color lineClearHighlight = Color(0xFF22D3EE);

  static const int lineClearPointPerCell = 2;
  static const double lineClearHighlightSeconds = 0.22;
  static const int angelChargePerTrigger = 2;
  static const int devilScoreBonus = 5;
  static const int devilSpawnCount = 2;
}
