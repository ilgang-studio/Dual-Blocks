part of '../../dual_blocks_game.dart';

// Game lifecycle: new game init, board reset, tray refill, game-over check.
extension _GameLifecycle on DualBlocksGame {
  void _startNewGame() {
    _clearBoard();
    score = 0;
    turn = 1;
    isGameOver = false;
    _angelStack = 0;
    _devilStack = 0;
    _comboShieldActive = false;
    _didClearLineThisTurn = false;
    _lastFateSelection = null;
    _storedScore = 0;
    _comboCount = 0;
    _displayScore = 0;
    _displayScoreStart = 0;
    _displayScoreTarget = 0;
    _displayScoreAnimElapsed = 0;
    _displayScoreAnimDuration = 0;
    _nextClearScoreMultiplier = 1.0;
    _angelEasyHandBoostPending = false;
    _guaranteeOneByOneNextTurn = false;
    _selectedDevilGift = null;
    _effectTime = 0;
    _activeFateType = null;
    _activeFateReason = null;
    _fateBannerLeft = 0;
    closeSettingsModal();
    _alignmentTurnSystem.turnCounter = 1;
    _refillTray(increaseTurn: false);
  }

  void _clearBoard() {
    for (var row = 0; row < board.length; row++) {
      for (var col = 0; col < board[row].length; col++) {
        board[row][col] = CellState.empty;
        _boardColorIndices[row][col] = null;
      }
    }
    _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
    _lineHighlightLeft = 0;
    _pendingClearResult = null;
    _pendingFateRemovalCells.clear();
    _pendingFateRemovalEffectType = null;
    _fateRemovalLeft = 0;
    _scorePopupLeft = 0;
    _scorePopupValue = 0;
    _scorePulseLeft = 0;
    _placeSuccessLeft = 0;
    _placeFailLeft = 0;
  }

  void _refillTray({required bool increaseTurn}) {
    if (increaseTurn) {
      _didClearLineThisTurn = false;
    }
    isAlignmentTurn = _alignmentTurnSystem.shouldStartAlignmentTurn();
    if (_guaranteeOneByOneNextTurn) {
      isAlignmentTurn = false;
    }
    if (isAlignmentTurn) {
      _buildAlignmentTray();
    } else {
      _buildNormalTray();
    }
    if (increaseTurn) turn += 1;
    _evaluateGameOver();
  }

  void _evaluateGameOver() {
    if (_pendingClearResult != null) {
      isGameOver = false;
      return;
    }
    if (_pendingFateRemovalCells.isNotEmpty) {
      isGameOver = false;
      return;
    }
    if (_alignmentChoicePending) {
      isGameOver = false;
      return;
    }
    final hasPlayable = GameFlowSystem.hasAnyPlaceableShape(
      board: board,
      trayBlocks: trayBlocks,
    );
    isGameOver = !hasPlayable;
    if (isGameOver) _clearDragState();
  }
}
