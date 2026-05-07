import 'dart:math' as math;

import 'package:dual_blocks/game/systems/turn/alignment_turn_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counter increments when roll does not pass probability', () {
    final system = AlignmentTurnSystem(
      random: math.Random(1),
      enableLogs: false,
    )..turnCounter = 1; // probability = 0.0, always false

    final started = system.shouldStartAlignmentTurn();

    expect(started, isFalse);
    expect(system.turnCounter, 2);
  });

  test('12th counter always triggers and resets to 1', () {
    final system = AlignmentTurnSystem(
      random: math.Random(2),
      enableLogs: false,
    )..turnCounter = 12; // probability = 1.0, always true

    final started = system.shouldStartAlignmentTurn();

    expect(started, isTrue);
    expect(system.turnCounter, 1);
  });

  test('counter is clamped to valid range and still behaves', () {
    final system = AlignmentTurnSystem(
      random: math.Random(3),
      enableLogs: false,
    )..turnCounter = 99;

    final started = system.shouldStartAlignmentTurn();

    expect(started, isTrue); // clamped to 12 -> probability 1.0
    expect(system.turnCounter, 1);
  });
}
