import 'package:dual_blocks/game/models/cell_state.dart';
import 'package:dual_blocks/game/systems/line_clear_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> boardOf(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => CellState.empty),
    );
  }

  test('detects full row and full column simultaneously', () {
    final board = boardOf(4);

    for (var col = 0; col < 4; col++) {
      board[1][col] = CellState.filled;
    }
    for (var row = 0; row < 4; row++) {
      board[row][2] = CellState.filled;
    }

    final result = LineClearSystem.findFilledLines(board);

    expect(result.fullRows, {1});
    expect(result.fullCols, {2});
  });

  test('clears row+col at once and counts unique cleared cells', () {
    final board = boardOf(4);

    for (var col = 0; col < 4; col++) {
      board[1][col] = CellState.filled;
    }
    for (var row = 0; row < 4; row++) {
      board[row][2] = CellState.filled;
    }

    final result = LineClearSystem.findFilledLines(board);
    final clearedCount = LineClearSystem.clearFilledLines(
      board: board,
      result: result,
    );

    expect(clearedCount, 7);
    for (var col = 0; col < 4; col++) {
      expect(board[1][col], CellState.empty);
    }
    for (var row = 0; row < 4; row++) {
      expect(board[row][2], CellState.empty);
    }
  });

  test('does not clear when there is no full row or column', () {
    final board = boardOf(4);
    board[0][0] = CellState.filled;
    board[1][1] = CellState.filled;
    board[2][2] = CellState.filled;

    final result = LineClearSystem.findFilledLines(board);
    final clearedCount = LineClearSystem.clearFilledLines(
      board: board,
      result: result,
    );

    expect(result.hasAny, isFalse);
    expect(clearedCount, 0);
    expect(board[0][0], CellState.filled);
    expect(board[1][1], CellState.filled);
    expect(board[2][2], CellState.filled);
  });
}
