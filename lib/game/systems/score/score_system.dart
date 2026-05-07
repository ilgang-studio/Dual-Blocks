import '../../config/game_constants.dart';
import '../../models/board/line_clear_result.dart';

class ScoreSystem {
  static int estimateClearedCellCount(LineClearResult result) {
    final rowCount = result.fullRows.length;
    final colCount = result.fullCols.length;
    return (rowCount * GameConstants.boardSize) +
        (colCount * GameConstants.boardSize) -
        (rowCount * colCount);
  }

  static int calculateLineClearScore({
    required int comboCount,
    required int clearedLineCount,
    bool applyBonusMultiplier = true,
  }) {
    if (clearedLineCount <= 0) return 0;
    if (!applyBonusMultiplier) {
      return clearedLineCount * GameConstants.lineClearBasePoint;
    }

    if (clearedLineCount == 1) {
      return (comboCount + 1) * GameConstants.lineClearBasePoint;
    }

    final multiLineScore =
        (comboCount + clearedLineCount) * GameConstants.lineClearBasePoint;
    return (multiLineScore *
            clearedLineCount *
            GameConstants.lineClearMultiLineBonusMultiplier)
        .round();
  }

  static ScoreApplyResult applyStoredScorePolicy({
    required int rawClearScore,
    required bool hasAngelStack,
    required int storedScore,
  }) {
    if (!hasAngelStack) {
      return ScoreApplyResult(
        grantedScore: rawClearScore,
        nextStoredScore: storedScore,
      );
    }

    final stored = (rawClearScore * GameConstants.angelStoreRatio).floor();
    return ScoreApplyResult(
      grantedScore: rawClearScore - stored,
      nextStoredScore: storedScore + stored,
    );
  }
}

class ScoreApplyResult {
  const ScoreApplyResult({
    required this.grantedScore,
    required this.nextStoredScore,
  });

  final int grantedScore;
  final int nextStoredScore;
}
