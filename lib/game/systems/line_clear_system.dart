import '../models/cell_state.dart';
import '../models/line_clear_result.dart';

class LineClearSystem {
  static LineClearResult findFilledLines(List<List<CellState>> board) {
    final fullRows = <int>{};
    final fullCols = <int>{};

    final rowCount = board.length;
    if (rowCount == 0) {
      return const LineClearResult(fullRows: {}, fullCols: {});
    }
    final colCount = board.first.length;

    for (var row = 0; row < rowCount; row++) {
      final isFull = board[row].every((cell) => cell.isOccupied);
      if (isFull) fullRows.add(row);
    }

    for (var col = 0; col < colCount; col++) {
      var isFull = true;
      for (var row = 0; row < rowCount; row++) {
        if (!board[row][col].isOccupied) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullCols.add(col);
    }

    return LineClearResult(fullRows: fullRows, fullCols: fullCols);
  }

  static int clearFilledLines({
    required List<List<CellState>> board,
    required LineClearResult result,
  }) {
    if (!result.hasAny) return 0;

    final rowCount = board.length;
    final colCount = rowCount == 0 ? 0 : board.first.length;
    final cleared = <int>{};

    for (final row in result.fullRows) {
      for (var col = 0; col < colCount; col++) {
        board[row][col] = CellState.empty;
        cleared.add((row * colCount) + col);
      }
    }

    for (final col in result.fullCols) {
      for (var row = 0; row < rowCount; row++) {
        board[row][col] = CellState.empty;
        cleared.add((row * colCount) + col);
      }
    }

    return cleared.length;
  }
}
