import 'dart:math' as math;

import '../models/block_shape.dart';
import '../models/cell_state.dart';
import 'placement_system.dart';

class HandGenerationSystem {
  static List<BlockShape> generateHand(
    List<List<CellState>> board, {
    required math.Random random,
    required List<BlockShape> blockPool,
    int handSize = 3,
    double Function(BlockShape shape)? weightResolver,
  }) {
    final selected = <BlockShape>[];
    final usedIds = <String>{};
    var bigBlockCount = 0;

    final shuffled = [...blockPool]..shuffle(random);

    for (final block in shuffled) {
      if (selected.length >= handSize) break;

      if (usedIds.contains(block.id)) continue;
      if (!canPlaceAnywhere(board, block)) continue;

      if (block.cells.length >= 4 && bigBlockCount >= 1) continue;

      final chance = random.nextDouble() * 10;
      final effectiveWeight = (weightResolver?.call(block) ?? block.weight)
          .clamp(0.0, 10.0);
      if (chance > effectiveWeight) continue;

      selected.add(block);
      usedIds.add(block.id);
      if (block.cells.length >= 4) bigBlockCount += 1;
    }

    if (selected.isEmpty) {
      final possibleBlocks = blockPool
          .where((shape) => canPlaceAnywhere(board, shape))
          .toList(growable: false);
      if (possibleBlocks.isNotEmpty) {
        final picked = possibleBlocks[random.nextInt(possibleBlocks.length)];
        selected.add(picked);
        usedIds.add(picked.id);
        if (picked.cells.length >= 4) bigBlockCount += 1;
      }
    }

    while (selected.length < handSize) {
      final placeableNonDup = blockPool
          .where((shape) => canPlaceAnywhere(board, shape))
          .where((shape) => !usedIds.contains(shape.id))
          .where((shape) => shape.cells.length < 4 || bigBlockCount < 1)
          .toList(growable: false);

      List<BlockShape> candidatePool;
      if (placeableNonDup.isNotEmpty) {
        candidatePool = placeableNonDup;
      } else {
        final placeableAny = blockPool
            .where((shape) => canPlaceAnywhere(board, shape))
            .toList(growable: false);
        candidatePool = placeableAny.isNotEmpty ? placeableAny : blockPool;
      }

      final picked = candidatePool[random.nextInt(candidatePool.length)];
      selected.add(picked);
      usedIds.add(picked.id);
      if (picked.cells.length >= 4) bigBlockCount += 1;
    }

    return selected;
  }

  static bool canPlaceAnywhere(List<List<CellState>> board, BlockShape block) {
    for (var row = 0; row < board.length; row++) {
      for (var col = 0; col < board[row].length; col++) {
        if (PlacementSystem.canPlaceShape(
          board: board,
          anchorRow: row,
          anchorCol: col,
          shape: block,
        )) {
          return true;
        }
      }
    }
    return false;
  }
}
