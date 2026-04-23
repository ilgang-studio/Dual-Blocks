import '../models/block_shape.dart';
import '../models/cell_state.dart';
import '../models/line_clear_result.dart';
import '../models/preview_clear_result.dart';

class LineClearSystem {
  static PreviewClearResult getPreviewClearLines({
    required List<List<CellState>> board,
    required BlockShape shape,
    required int anchorRow,
    required int anchorCol,
    CellState fillState = CellState.filled,
  }) {
    if (!_canPlaceShape(
      board: board,
      shape: shape,
      anchorRow: anchorRow,
      anchorCol: anchorCol,
    )) {
      return PreviewClearResult.empty;
    }

    final tempBoard = board
        .map((row) => List<CellState>.from(row))
        .toList(growable: false);
    for (final cell in shape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      tempBoard[row][col] = fillState;
    }

    final lines = findFilledLines(tempBoard);
    return PreviewClearResult(rows: lines.fullRows, cols: lines.fullCols);
  }

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

  static bool _canPlaceShape({
    required List<List<CellState>> board,
    required BlockShape shape,
    required int anchorRow,
    required int anchorCol,
  }) {
    final rowCount = board.length;
    if (rowCount == 0) return false;
    final colCount = board.first.length;

    for (final cell in shape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      if (row < 0 || row >= rowCount || col < 0 || col >= colCount) {
        return false;
      }
      if (board[row][col].isOccupied) return false;
    }
    return true;
  }
}
