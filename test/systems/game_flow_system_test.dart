import 'package:dual_blocks/game/models/block_shape.dart';
import 'package:dual_blocks/game/models/cell_state.dart';
import 'package:dual_blocks/game/systems/game_flow_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<List<CellState>> boardOf(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => CellState.empty),
    );
  }

  test('returns true when at least one tray shape can be placed', () {
    final board = boardOf(4);
    final tray = <BlockShape?>[BlockCatalog.l3, null, null];

    final canPlace = GameFlowSystem.hasAnyPlaceableShape(
      board: board,
      trayBlocks: tray,
    );

    expect(canPlace, isTrue);
  });

  test('returns false when no tray shape can be placed', () {
    final board = boardOf(4);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        board[row][col] = CellState.filled;
      }
    }

    final tray = <BlockShape?>[BlockCatalog.single, BlockCatalog.line2H, null];

    final canPlace = GameFlowSystem.hasAnyPlaceableShape(
      board: board,
      trayBlocks: tray,
    );

    expect(canPlace, isFalse);
  });
}
