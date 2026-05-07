import '../../models/block/block_shape.dart';
import '../../models/board/cell_state.dart';
import '../board/placement_system.dart';

class GameFlowSystem {
  static bool hasAnyPlaceableShape({
    required List<List<CellState>> board,
    required List<BlockShape?> trayBlocks,
  }) {
    final shapes = trayBlocks.whereType<BlockShape>();
    for (final shape in shapes) {
      if (_canPlaceShapeAnywhere(board: board, shape: shape)) {
        return true;
      }
    }
    return false;
  }

  static bool _canPlaceShapeAnywhere({
    required List<List<CellState>> board,
    required BlockShape shape,
  }) {
    final rowCount = board.length;
    if (rowCount == 0) return false;
    final colCount = board.first.length;

    for (var row = 0; row < rowCount; row++) {
      for (var col = 0; col < colCount; col++) {
        if (PlacementSystem.canPlaceShape(
          board: board,
          anchorRow: row,
          anchorCol: col,
          shape: shape,
        )) {
          return true;
        }
      }
    }
    return false;
  }
}
