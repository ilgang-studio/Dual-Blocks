import '../config/game_constants.dart';
import '../models/block_shape.dart';
import '../models/cell_state.dart';
import 'placement_system.dart';

class DevilBlockSystem {
  static BlockShape? pickDestructionAidBlock({
    required List<List<CellState>> board,
    required List<BlockShape> blockPool,
  }) {
    final candidates = blockPool.toList(growable: false)
      ..sort((a, b) => a.cells.length.compareTo(b.cells.length));

    for (final block in candidates) {
      if (block.cells.length > 3) continue;
      if (_canPlaceAnywhere(board: board, shape: block)) return block;
    }

    for (final block in candidates) {
      if (_canPlaceAnywhere(board: board, shape: block)) return block;
    }
    return null;
  }

  static bool _canPlaceAnywhere({
    required List<List<CellState>> board,
    required BlockShape shape,
  }) {
    for (var row = 0; row < GameConstants.boardSize; row++) {
      for (var col = 0; col < GameConstants.boardSize; col++) {
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
