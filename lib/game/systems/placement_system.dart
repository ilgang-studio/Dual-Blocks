import '../models/cell_state.dart';

class PlacementSystem {
  static bool canPlace({
    required List<List<CellState>> board,
    required int row,
    required int col,
  }) {
    if (!_isInBounds(board: board, row: row, col: col)) return false;
    return board[row][col] == CellState.empty;
  }

  static bool placeBlock({
    required List<List<CellState>> board,
    required int row,
    required int col,
  }) {
    if (!canPlace(board: board, row: row, col: col)) return false;
    board[row][col] = CellState.filled;
    return true;
  }

  static bool _isInBounds({
    required List<List<CellState>> board,
    required int row,
    required int col,
  }) {
    final rowCount = board.length;
    if (rowCount == 0) return false;
    final colCount = board.first.length;

    return row >= 0 && row < rowCount && col >= 0 && col < colCount;
  }
}
