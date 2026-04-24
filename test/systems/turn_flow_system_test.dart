import 'package:dual_blocks/game/models/block/block_shape.dart';
import 'package:dual_blocks/game/systems/turn/turn_flow_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nextSelectedIndex returns first non-null tray index', () {
    final tray = <BlockShape?>[null, BlockCatalog.single, BlockCatalog.line2];
    final next = TurnFlowSystem.nextSelectedIndex(tray);
    expect(next, 1);
  });

  test('nextSelectedIndex returns null when tray is empty', () {
    final tray = <BlockShape?>[null, null, null];
    final next = TurnFlowSystem.nextSelectedIndex(tray);
    expect(next, isNull);
  });

  test('shouldRefillTray is true only when all slots are consumed', () {
    final notEmpty = <BlockShape?>[null, BlockCatalog.single, null];
    final allEmpty = <BlockShape?>[null, null, null];

    expect(TurnFlowSystem.shouldRefillTray(notEmpty), isFalse);
    expect(TurnFlowSystem.shouldRefillTray(allEmpty), isTrue);
  });
}
