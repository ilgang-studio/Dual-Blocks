import 'dart:math' as math;

import 'package:dual_blocks/game/models/block/block_shape.dart';
import 'package:dual_blocks/game/models/board/cell_state.dart';
import 'package:dual_blocks/game/systems/hand/hand_generation_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> boardOf(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => CellState.empty),
    );
  }

  test('generateHand returns 3 blocks and avoids duplicates when possible', () {
    final board = boardOf(8);
    final hand = HandGenerationSystem.generateHand(
      board,
      random: math.Random(7),
      blockPool: BlockCatalog.pool,
      handSize: 3,
    );

    expect(hand.length, 3);
    expect(hand.map((b) => b.id).toSet().length, 3);
  });

  test('generateHand limits big blocks (4+ cells) to at most one', () {
    final board = boardOf(8);
    final hand = HandGenerationSystem.generateHand(
      board,
      random: math.Random(15),
      blockPool: BlockCatalog.pool,
      handSize: 3,
    );

    final bigCount = hand.where((shape) => shape.cells.length >= 4).length;
    expect(bigCount <= 1, isTrue);
  });

  test(
    'generateHand guarantees at least one placeable block when possible',
    () {
      final board = boardOf(8);
      final impossibleByWeight = [
        const BlockShape(
          id: 'forced',
          cells: [math.Point<int>(0, 0)],
          weight: -1,
        ),
      ];

      final hand = HandGenerationSystem.generateHand(
        board,
        random: math.Random(1),
        blockPool: impossibleByWeight,
        handSize: 3,
      );

      expect(hand.isNotEmpty, isTrue);
      expect(HandGenerationSystem.canPlaceAnywhere(board, hand.first), isTrue);
    },
  );

  test('canPlaceAnywhere returns false when board is full', () {
    final board = boardOf(4);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        board[row][col] = CellState.filled;
      }
    }

    final canPlace = HandGenerationSystem.canPlaceAnywhere(
      board,
      BlockCatalog.single,
    );
    expect(canPlace, isFalse);
  });
}
