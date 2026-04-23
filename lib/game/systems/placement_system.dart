import '../models/cell_state.dart';
import '../models/block_shape.dart';

class PlacementSystem {
  static bool canPlace({
    required List<List<CellState>> board,
    required int row,
    required int col,
  }) {
    if (!_isInBounds(board: board, row: row, col: col)) return false;
    return !board[row][col].isOccupied;
  }

  static bool placeBlock({
    required List<List<CellState>> board,
    required int row,
    required int col,
    CellState fillState = CellState.filled,
  }) {
    if (!canPlace(board: board, row: row, col: col)) return false;
    board[row][col] = fillState;
    return true;
  }

  static bool canPlaceShape({
    required List<List<CellState>> board,
    required int anchorRow,
    required int anchorCol,
    required BlockShape shape,
  }) {
    for (final cell in shape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      if (!canPlace(board: board, row: row, col: col)) return false;
    }
    return true;
  }

  static bool placeShape({
    required List<List<CellState>> board,
    required int anchorRow,
    required int anchorCol,
    required BlockShape shape,
    CellState fillState = CellState.filled,
  }) {
    if (!canPlaceShape(
      board: board,
      anchorRow: anchorRow,
      anchorCol: anchorCol,
      shape: shape,
    )) {
      return false;
    }

    for (final cell in shape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      board[row][col] = fillState;
    }
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
