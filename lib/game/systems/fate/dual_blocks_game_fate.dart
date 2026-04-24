part of '../../dual_blocks_game.dart';

// Fate system: angel / devil selection, triggers, removal effects.
extension _GameFate on DualBlocksGame {
  void selectAngel() {
    if (_lastFateSelection == FateType.devil) {
      _applyDevilToAngelSwitchPenalty();
    }
    _lastFateSelection = FateType.angel;
    _angelStack += 1;
    _selectedFate = FateType.angel;
    if (_angelStack >= GameConstants.fateTriggerStack) {
      triggerAngel();
      _angelStack = 0;
    }
  }

  void selectDevil() {
    _lastFateSelection = FateType.devil;
    _devilStack += 1;
    _selectedFate = FateType.devil;
    if (_devilStack >= GameConstants.fateTriggerStack) {
      triggerDevil();
      _devilStack = 0;
    }
  }

  void triggerAngel() {
    final payout = _storedScore;
    score += payout;
    _showScoreGainFeedback(payout);
    _storedScore = 0;

    String effectSummary;
    if (!_didClearLineThisTurn && _comboCount > 0) {
      _comboShieldActive = true;
      effectSummary = 'Combo shield ready (1 turn)';
    } else {
      final removed = _queueMostFilledLineRemoval();
      effectSummary = 'Most-filled line cleanup: $removed cell(s)';
    }

    _showFateBanner(FateType.angel, 'Stored +$payout, $effectSummary');
    debugPrint('[Angel Triggered] payout=$payout effect=$effectSummary');
    _evaluateGameOver();
  }

  void triggerDevil() {
    final selectedGift = FateEffectSystem.chooseDevilGiftType(
      random: _random,
      preferred: _selectedDevilGift,
    );
    _selectedDevilGift = null;

    score = (score * 0.9).toInt();

    String summary;
    if (selectedGift == DevilGiftType.seedOfRuin) {
      _guaranteeOneByOneNextTurn = true;
      summary = 'Seed of Ruin: next hand includes 1x1';
    } else {
      _removeRandomShapeNextTurn = true;
      summary = 'Entropy Tax: remove 1 random shape from next hand';
    }

    _showFateBanner(FateType.devil, '$summary, -10% score');
    debugPrint('[Devil Triggered] $summary');
    _evaluateGameOver();
  }

  void _showFateBanner(FateType type, String reason) {
    _activeFateType = type;
    _activeFateReason = reason;
    _fateBannerLeft = GameConstants.fateBannerSeconds;
  }

  int _queueMostFilledLineRemoval() {
    final line = FateEffectSystem.findMostFilledLine(board: board);
    if (line == null) return 0;
    if (line.cells.isEmpty) return 0;
    _queueFateRemoval(line.cells, FateRemovalEffectType.angelPurge);
    return line.cells.length;
  }

  void _applyDevilToAngelSwitchPenalty() {
    score = (score * (1 - DualBlocksGame._devilToAngelSwitchPenaltyRatio))
        .toInt();
  }

  void _queueFateRemoval(
    List<math.Point<int>> cells,
    FateRemovalEffectType effectType,
  ) {
    if (cells.isEmpty) return;
    _pendingFateRemovalCells
      ..clear()
      ..addAll(cells);
    _pendingFateRemovalEffectType = effectType;
    _fateRemovalLeft = GameConstants.fateRemovalEffectSeconds;
  }

  void _resolvePendingFateRemoval() {
    if (_pendingFateRemovalCells.isEmpty) return;
    for (final point in _pendingFateRemovalCells) {
      final col = point.x;
      final row = point.y;
      if (row < 0 ||
          row >= GameConstants.boardSize ||
          col < 0 ||
          col >= GameConstants.boardSize) {
        continue;
      }
      board[row][col] = CellState.empty;
      _boardColorIndices[row][col] = null;
    }
    _pendingFateRemovalCells.clear();
    _pendingFateRemovalEffectType = null;
    _fateRemovalLeft = 0;
    _evaluateGameOver();
  }
}
