part of 'dual_blocks_game.dart';

// Fate system: angel / devil selection, triggers, removal effects.
extension _GameFate on DualBlocksGame {
  void selectAngel() {
    _angelStack += 1;
    _devilStack = 0;
    _selectedFate = FateType.angel;
    if (_angelStack >= GameConstants.fateTriggerStack) {
      triggerAngel();
      _angelStack = 0;
    }
  }

  void selectDevil() {
    _devilStack += 1;
    _angelStack = 0;
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

    var effectSummary = '';
    switch (GameConstants.angelEffectMode) {
      case AngelEffectMode.rescueCleanup:
        final removed = _rescueCleanup();
        effectSummary = 'Rescue cleanup removed $removed cell';
      case AngelEffectMode.scoreShield:
        _nextClearScoreMultiplier = GameConstants.angelNextClearScoreMultiplier;
        effectSummary =
            'Next clear score x${GameConstants.angelNextClearScoreMultiplier.toStringAsFixed(1)}';
      case AngelEffectMode.handRefine:
        _angelEasyHandBoostPending = true;
        effectSummary = 'Next normal hand refined to easier blocks';
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

    score = (score * (1 - GameConstants.devilScorePenaltyRatio)).toInt();

    String summary;
    if (selectedGift == DevilGiftType.greedBestBlock) {
      _pendingDevilGift = DevilGiftType.greedBestBlock;
      summary = 'Greed: next hand gets best block';
    } else {
      _pendingDevilGift = null;
      final removed = _queueDevilDestructionRemoval(2);
      summary = 'Destruction: collapse $removed block(s)';
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

  int _rescueCleanup() {
    final target = FateEffectSystem.findRescueCleanupCell(
      board: board,
      random: _random,
    );
    if (target == null) return 0;
    _queueFateRemoval([target], FateRemovalEffectType.angelPurge);
    return 1;
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

  int _queueDevilDestructionRemoval(int targetCount) {
    final picked = FateEffectSystem.pickDestructionCells(
      board: board,
      random: _random,
      targetCount: targetCount,
    );
    if (picked.isEmpty) return 0;
    _queueFateRemoval(picked, FateRemovalEffectType.devilBlast);
    return picked.length;
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
