import '../config/game_constants.dart';
import '../models/block_shape.dart';
import '../models/cell_state.dart';
import 'line_clear_system.dart';
import 'placement_system.dart';

class DevilBlockSystem {
  static BlockShape? findBestBlock({
    required List<List<CellState>> board,
    required List<BlockShape> blockPool,
  }) {
    BlockShape? bestBlock;
    var bestScore = -1;
    var bestSize = 1 << 30;

    for (final block in blockPool) {
      if (!_canPlaceAnywhere(board: board, shape: block)) continue;

      var blockBestScore = -1;
      for (var row = 0; row < GameConstants.boardSize; row++) {
        for (var col = 0; col < GameConstants.boardSize; col++) {
          if (!PlacementSystem.canPlaceShape(
            board: board,
            anchorRow: row,
            anchorCol: col,
            shape: block,
          )) {
            continue;
          }
          final score = _simulatePlacementScore(
            board: board,
            shape: block,
            row: row,
            col: col,
          );
          if (score > blockBestScore) {
            blockBestScore = score;
          }
        }
      }

      if (blockBestScore > bestScore) {
        bestScore = blockBestScore;
        bestBlock = block;
        bestSize = block.cells.length;
        continue;
      }

      if (blockBestScore == bestScore && block.cells.length < bestSize) {
        bestBlock = block;
        bestSize = block.cells.length;
      }
    }

    return bestBlock;
  }

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

  static int _simulatePlacementScore({
    required List<List<CellState>> board,
    required BlockShape shape,
    required int row,
    required int col,
  }) {
    final simBoard = board
        .map((line) => line.toList(growable: false))
        .toList(growable: false);

    final placed = PlacementSystem.placeShape(
      board: simBoard,
      anchorRow: row,
      anchorCol: col,
      shape: shape,
      fillState: CellState.filled,
    );
    if (!placed) return -1;

    final result = LineClearSystem.findFilledLines(simBoard);
    if (!result.hasAny) return 0;

    final clearedCells = LineClearSystem.clearFilledLines(
      board: simBoard,
      result: result,
    );
    final lineCount = result.fullRows.length + result.fullCols.length;
    return lineCount * 100 + clearedCells;
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
