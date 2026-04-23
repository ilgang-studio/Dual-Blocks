import 'package:dual_blocks/game/models/cell_state.dart';
import 'package:dual_blocks/game/models/fate_effect.dart';
import 'package:dual_blocks/game/systems/fate_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> boardOf(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => CellState.empty),
    );
  }

  test('angel triggers on clear streak', () {
    final decision = FateSystem.evaluate(
      clearedCellCount: 2,
      clearStreak: 2,
      noClearStreak: 0,
      fillRatio: 0.2,
    );

    expect(decision, isNotNull);
    expect(decision!.type, FateType.angel);
  });

  test('devil triggers on no-clear streak', () {
    final decision = FateSystem.evaluate(
      clearedCellCount: 0,
      clearStreak: 0,
      noClearStreak: 3,
      fillRatio: 0.2,
    );

    expect(decision, isNotNull);
    expect(decision!.type, FateType.devil);
  });

  test('devil wins when angel and devil trigger together', () {
    final decision = FateSystem.evaluate(
      clearedCellCount: 9,
      clearStreak: 2,
      noClearStreak: 3,
      fillRatio: 0.8,
    );

    expect(decision, isNotNull);
    expect(decision!.type, FateType.devil);
  });

  test('fillRatio calculates from board occupancy', () {
    final board = boardOf(4);
    board[0][0] = CellState.filled;
    board[0][1] = CellState.filled;
    board[1][0] = CellState.filled;
    board[2][2] = CellState.filled;

    final ratio = FateSystem.fillRatio(board);
    expect(ratio, closeTo(0.25, 0.0001));
  });
}
