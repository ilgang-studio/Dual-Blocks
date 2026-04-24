import 'dart:math' as math;

import '../../config/game_constants.dart';
import '../../models/board/cell_state.dart';
import '../../models/fate/fate_effect.dart';

class FateEffectSystem {
  static DevilGiftType chooseDevilGiftType({
    required math.Random random,
    DevilGiftType? preferred,
  }) {
    return preferred ??
        (random.nextBool()
            ? DevilGiftType.seedOfRuin
            : DevilGiftType.randomShapeDelete);
  }

  static math.Point<int>? findRescueCleanupCell({
    required List<List<CellState>> board,
    required math.Random random,
  }) {
    _LineTarget? bestTarget;
    var bestOccupiedCount = 0;

    for (var row = 0; row < board.length; row++) {
      var occupied = 0;
      for (var col = 0; col < board[row].length; col++) {
        if (board[row][col].isOccupied) occupied += 1;
      }
      if (occupied <= 0 || occupied >= GameConstants.boardSize) continue;
      if (occupied > bestOccupiedCount) {
        bestOccupiedCount = occupied;
        bestTarget = _LineTarget.row(row);
      }
    }

    for (var col = 0; col < GameConstants.boardSize; col++) {
      var occupied = 0;
      for (var row = 0; row < GameConstants.boardSize; row++) {
        if (board[row][col].isOccupied) occupied += 1;
      }
      if (occupied <= 0 || occupied >= GameConstants.boardSize) continue;
      if (occupied > bestOccupiedCount) {
        bestOccupiedCount = occupied;
        bestTarget = _LineTarget.col(col);
      }
    }

    final target = bestTarget;
    if (target == null) return null;

    if (target.axis == _LineAxis.row) {
      final row = target.index;
      final occupiedCols = <int>[];
      for (var col = 0; col < GameConstants.boardSize; col++) {
        if (board[row][col].isOccupied) occupiedCols.add(col);
      }
      if (occupiedCols.isEmpty) return null;
      final col = occupiedCols[random.nextInt(occupiedCols.length)];
      return math.Point<int>(col, row);
    }

    final col = target.index;
    final occupiedRows = <int>[];
    for (var row = 0; row < GameConstants.boardSize; row++) {
      if (board[row][col].isOccupied) occupiedRows.add(row);
    }
    if (occupiedRows.isEmpty) return null;
    final row = occupiedRows[random.nextInt(occupiedRows.length)];
    return math.Point<int>(col, row);
  }

  static MostFilledLine? findMostFilledLine({
    required List<List<CellState>> board,
  }) {
    MostFilledLine? best;
    var bestCount = 0;

    for (var row = 0; row < board.length; row++) {
      final cells = <math.Point<int>>[];
      for (var col = 0; col < board[row].length; col++) {
        if (board[row][col].isOccupied) {
          cells.add(math.Point<int>(col, row));
        }
      }
      if (cells.length > bestCount) {
        bestCount = cells.length;
        best = MostFilledLine(
          axis: MostFilledAxis.row,
          index: row,
          cells: cells,
        );
      }
    }

    for (var col = 0; col < GameConstants.boardSize; col++) {
      final cells = <math.Point<int>>[];
      for (var row = 0; row < GameConstants.boardSize; row++) {
        if (board[row][col].isOccupied) {
          cells.add(math.Point<int>(col, row));
        }
      }
      if (cells.length > bestCount) {
        bestCount = cells.length;
        best = MostFilledLine(
          axis: MostFilledAxis.col,
          index: col,
          cells: cells,
        );
      }
    }

    return bestCount > 0 ? best : null;
  }

  static List<math.Point<int>> pickDestructionCells({
    required List<List<CellState>> board,
    required math.Random random,
    required int targetCount,
  }) {
    final occupied = <math.Point<int>>[];
    for (var row = 0; row < GameConstants.boardSize; row++) {
      for (var col = 0; col < GameConstants.boardSize; col++) {
        if (board[row][col].isOccupied) {
          occupied.add(math.Point<int>(col, row));
        }
      }
    }
    if (occupied.isEmpty) return const [];

    occupied.shuffle(random);
    final count = targetCount.clamp(1, occupied.length);
    return occupied.take(count).toList(growable: false);
  }
}

enum _LineAxis { row, col }

class _LineTarget {
  const _LineTarget._(this.axis, this.index);

  final _LineAxis axis;
  final int index;

  factory _LineTarget.row(int row) => _LineTarget._(_LineAxis.row, row);
  factory _LineTarget.col(int col) => _LineTarget._(_LineAxis.col, col);
}

enum MostFilledAxis { row, col }

class MostFilledLine {
  const MostFilledLine({
    required this.axis,
    required this.index,
    required this.cells,
  });

  final MostFilledAxis axis;
  final int index;
  final List<math.Point<int>> cells;
}
