import '../models/cell_state.dart';
import '../models/fate_effect.dart';

class FateSystem {
  static FateDecision? evaluate({
    required int clearedCellCount,
    required int clearStreak,
    required int noClearStreak,
    required double fillRatio,
  }) {
    final angelByClear = clearedCellCount >= 8;
    final angelByStreak = clearStreak >= 2;
    final devilByNoClear = noClearStreak >= 3;
    final devilByDensity = fillRatio >= 0.72;

    final angelTriggered = angelByClear || angelByStreak;
    final devilTriggered = devilByNoClear || devilByDensity;

    // Priority rule: devil overrides angel when both triggers happen.
    if (devilTriggered) {
      final reason = devilByDensity
          ? 'Board density is high'
          : 'No-clear streak reached';
      return FateDecision(type: FateType.devil, reason: reason);
    }
    if (angelTriggered) {
      final reason = angelByStreak
          ? 'Clear streak reached'
          : 'Large clear achieved';
      return FateDecision(type: FateType.angel, reason: reason);
    }
    return null;
  }

  static int filledCellCount(List<List<CellState>> board) {
    var count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == CellState.filled) count += 1;
      }
    }
    return count;
  }

  static double fillRatio(List<List<CellState>> board) {
    final rowCount = board.length;
    if (rowCount == 0) return 0;
    final colCount = board.first.length;
    if (colCount == 0) return 0;
    final total = rowCount * colCount;
    return filledCellCount(board) / total;
  }
}
