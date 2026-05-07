import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class AlignmentTurnSystem {
  AlignmentTurnSystem({math.Random? random, this.enableLogs = true})
    : random = random ?? math.Random();

  int turnCounter = 1;
  final math.Random random;
  final bool enableLogs;

  static const Map<int, double> probabilityTable = {
    1: 0.00,
    2: 0.03,
    3: 0.05,
    4: 0.08,
    5: 0.12,
    6: 0.17,
    7: 0.23,
    8: 0.30,
    9: 0.40,
    10: 0.52,
    11: 0.70,
    12: 1.00,
  };

  bool shouldStartAlignmentTurn() {
    final current = turnCounter.clamp(1, 12);
    final probability = probabilityTable[current] ?? 1.0;
    final roll = random.nextDouble();

    if (enableLogs) {
      debugPrint(
        '[ALIGN] turnCounter=$current probability=$probability roll=$roll',
      );
    }

    final shouldStart = roll < probability;
    if (shouldStart) {
      turnCounter = 1;
      return true;
    }

    turnCounter = (current + 1).clamp(1, 12);
    return false;
  }
}
