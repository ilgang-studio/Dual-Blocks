import 'package:dual_blocks/game/models/line_clear_result.dart';
import 'package:dual_blocks/game/systems/score_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculateLineClearScore handles single line with combo', () {
    final score = ScoreSystem.calculateLineClearScore(
      comboCount: 10,
      clearedLineCount: 1,
    );
    expect(score, 110);
  });

  test('calculateLineClearScore handles multi line formula', () {
    final score = ScoreSystem.calculateLineClearScore(
      comboCount: 10,
      clearedLineCount: 3,
    );
    expect(score, 780);
  });

  test('estimateClearedCellCount counts row/col overlap once', () {
    final count = ScoreSystem.estimateClearedCellCount(
      const LineClearResult(fullRows: {1}, fullCols: {2}),
    );
    expect(count, 15);
  });

  test(
    'applyStoredScorePolicy stores part of score while angel stack active',
    () {
      final result = ScoreSystem.applyStoredScorePolicy(
        rawClearScore: 100,
        hasAngelStack: true,
        storedScore: 20,
      );
      expect(result.grantedScore, 50);
      expect(result.nextStoredScore, 70);
    },
  );
}
