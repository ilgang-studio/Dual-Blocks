import 'package:dual_blocks/game/models/block_shape.dart';
import 'package:dual_blocks/game/models/cell_state.dart';
import 'package:dual_blocks/game/systems/devil_block_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> emptyBoard() =>
      List.generate(8, (_) => List.generate(8, (_) => CellState.empty));

  test('findBestBlock picks block that can clear more lines', () {
    final board = emptyBoard();
    for (var col = 0; col < 6; col++) {
      board[0][col] = CellState.filled;
    }

    final best = DevilBlockSystem.findBestBlock(
      board: board,
      blockPool: const [
        BlockCatalog.single,
        BlockCatalog.line2,
        BlockCatalog.line2V,
      ],
    );

    expect(best, isNotNull);
    expect(best!.id, equals(BlockCatalog.line2.id));
  });

  test('findBestBlock uses smaller block on tied score', () {
    final board = emptyBoard();

    final best = DevilBlockSystem.findBestBlock(
      board: board,
      blockPool: const [BlockCatalog.line2, BlockCatalog.single],
    );

    expect(best, isNotNull);
    expect(best!.id, equals(BlockCatalog.single.id));
  });

  test('findBestBlock returns null when no block is placeable', () {
    final board = emptyBoard();
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        board[row][col] = CellState.filled;
      }
    }

    final best = DevilBlockSystem.findBestBlock(
      board: board,
      blockPool: const [BlockCatalog.single, BlockCatalog.line2],
    );

    expect(best, isNull);
  });

  test('pickDestructionAidBlock prefers small placeable blocks', () {
    final board = emptyBoard();
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        board[row][col] = CellState.filled;
      }
    }
    board[7][7] = CellState.empty;

    final picked = DevilBlockSystem.pickDestructionAidBlock(
      board: board,
      blockPool: const [
        BlockCatalog.line2,
        BlockCatalog.single,
        BlockCatalog.square2,
      ],
    );

    expect(picked, isNotNull);
    expect(picked!.id, equals(BlockCatalog.single.id));
  });
}
