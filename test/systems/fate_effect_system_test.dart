import 'dart:math' as math;

import 'package:dual_blocks/game/models/cell_state.dart';
import 'package:dual_blocks/game/models/fate_effect.dart';
import 'package:dual_blocks/game/systems/fate_effect_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> boardOf(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => CellState.empty),
    );
  }

  test('chooseDevilGiftType respects preferred gift when provided', () {
    final picked = FateEffectSystem.chooseDevilGiftType(
      random: math.Random(0),
      preferred: DevilGiftType.seedOfRuin,
    );
    expect(picked, DevilGiftType.seedOfRuin);
  });

  test(
    'findRescueCleanupCell returns occupied cell from most filled near-complete line',
    () {
      final board = boardOf(8);
      for (var col = 0; col < 7; col++) {
        board[2][col] = CellState.filled;
      }

      final cell = FateEffectSystem.findRescueCleanupCell(
        board: board,
        random: math.Random(0),
      );

      expect(cell, isNotNull);
      expect(cell!.y, 2);
      expect(board[cell.y][cell.x].isOccupied, isTrue);
    },
  );

  test(
    'pickDestructionCells returns only occupied cells up to target count',
    () {
      final board = boardOf(8);
      board[1][1] = CellState.filled;
      board[2][3] = CellState.filled;
      board[4][5] = CellState.filled;

      final picked = FateEffectSystem.pickDestructionCells(
        board: board,
        random: math.Random(1),
        targetCount: 2,
      );

      expect(picked.length, 2);
      for (final cell in picked) {
        expect(board[cell.y][cell.x].isOccupied, isTrue);
      }
    },
  );
}
