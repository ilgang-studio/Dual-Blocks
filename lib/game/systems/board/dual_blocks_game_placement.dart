part of '../../dual_blocks_game.dart';

// Block placement, line-clear resolution, destruction blocks, drop preview.
extension _GamePlacement on DualBlocksGame {
  CellState get _currentFillState {
    if (_selectedFate == FateType.angel) return CellState.angelFilled;
    if (_selectedFate == FateType.devil) return CellState.devilFilled;
    return CellState.filled;
  }

  bool get _isSelectedDestructionBlock =>
      _selectedFate == FateType.devil &&
      _selectedTrayDevilGift == DevilGiftType.destructionAid;

  bool canPlace(int row, int col) {
    if (_pendingClearResult != null) return false;
    if (_pendingFateRemovalCells.isNotEmpty) return false;
    if (_isSelectedDestructionBlock) return _canApplyDestructionShape(row, col);
    final selectedShape = _selectedShape;
    if (selectedShape == null) return false;
    return PlacementSystem.canPlaceShape(
      board: board,
      anchorRow: row,
      anchorCol: col,
      shape: selectedShape,
    );
  }

  bool placeBlock(int row, int col) {
    if (isGameOver) return false;
    if (_isSelectedDestructionBlock) {
      if (!canPlace(row, col)) return false;
      _applyDestructionShape(row, col);
      _consumeSelectedTrayBlock();
      return true;
    }

    final selectedShape = _selectedShape;
    if (selectedShape == null) return false;

    final placed = PlacementSystem.placeShape(
      board: board,
      anchorRow: row,
      anchorCol: col,
      shape: selectedShape,
      fillState: _currentFillState,
    );
    if (placed) {
      final isOneByOne = selectedShape.id == BlockCatalog.single.id;
      _paintPlacedBlockColor(row, col, selectedShape);
      final placedScore = selectedShape.cells.length;
      score += placedScore;
      final clearGain = _applyLineClear(applyBonusMultiplier: !isOneByOne);
      _showScoreGainFeedback(placedScore + clearGain);
      _consumeSelectedTrayBlock();
    }
    return placed;
  }

  int _applyLineClear({required bool applyBonusMultiplier}) {
    final result = LineClearSystem.findFilledLines(board);
    if (!result.hasAny) {
      if (_comboCount > 0 && _comboShieldActive) {
        _comboShieldActive = false;
        return 0;
      }
      if (_comboCount > 0 && _comboGraceMissesLeft > 0) {
        _comboGraceMissesLeft -= 1;
        return 0;
      }
      _comboCount = 0;
      _comboGraceMissesLeft = 0;
      return 0;
    }

    _didClearLineThisTurn = true;
    _lastClearResult = result;
    _lineHighlightLeft = GameConstants.lineClearHighlightSeconds;
    _pendingClearResult = result;
    final clearedLineCount = result.fullRows.length + result.fullCols.length;
    final clearScore = ScoreSystem.calculateLineClearScore(
      comboCount: _comboCount,
      clearedLineCount: clearedLineCount,
      applyBonusMultiplier: applyBonusMultiplier,
    );
    _comboCount += 1;
    // Keep combo alive for one miss so combo doesn't drop immediately.
    _comboGraceMissesLeft = 1;

    var scoredClear = clearScore;
    if (_nextClearScoreMultiplier > 1.0) {
      scoredClear = (clearScore * _nextClearScoreMultiplier).round();
      _nextClearScoreMultiplier = 1.0;
    }

    final scoreResult = ScoreSystem.applyStoredScorePolicy(
      rawClearScore: scoredClear,
      hasAngelStack: _angelStack > 0,
      storedScore: _storedScore,
    );
    _storedScore = scoreResult.nextStoredScore;
    score += scoreResult.grantedScore;
    return scoreResult.grantedScore;
  }

  void _resolvePendingLineClear() {
    final pending = _pendingClearResult;
    if (pending == null) return;

    for (final row in pending.fullRows) {
      for (var col = 0; col < GameConstants.boardSize; col++) {
        _boardColorIndices[row][col] = null;
      }
    }
    for (final col in pending.fullCols) {
      for (var row = 0; row < GameConstants.boardSize; row++) {
        _boardColorIndices[row][col] = null;
      }
    }

    LineClearSystem.clearFilledLines(board: board, result: pending);
    _pendingClearResult = null;
    _lineHighlightLeft = 0;
    _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
    _evaluateGameOver();
  }

  void _paintPlacedBlockColor(int anchorRow, int anchorCol, BlockShape shape) {
    if (_currentFillState != CellState.filled) return;
    final colorIndex = _selectedTrayBlockColorIndex ?? _nextRainbowColorIndex();
    for (final cell in shape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      if (row < 0 ||
          row >= GameConstants.boardSize ||
          col < 0 ||
          col >= GameConstants.boardSize) {
        continue;
      }
      _boardColorIndices[row][col] = colorIndex;
    }
  }

  bool _canApplyDestructionShape(int anchorRow, int anchorCol) {
    final selectedShape = _selectedShape;
    if (selectedShape == null) return false;

    var hasOccupiedTarget = false;
    for (final cell in selectedShape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      if (row < 0 ||
          row >= GameConstants.boardSize ||
          col < 0 ||
          col >= GameConstants.boardSize) {
        return false;
      }
      if (board[row][col].isOccupied) hasOccupiedTarget = true;
    }
    return hasOccupiedTarget;
  }

  void _applyDestructionShape(int anchorRow, int anchorCol) {
    final selectedShape = _selectedShape;
    if (selectedShape == null) return;
    final removalTargets = <math.Point<int>>[];

    for (final cell in selectedShape.cells) {
      final row = anchorRow + cell.y;
      final col = anchorCol + cell.x;
      if (row < 0 ||
          row >= GameConstants.boardSize ||
          col < 0 ||
          col >= GameConstants.boardSize) {
        continue;
      }
      if (!board[row][col].isOccupied) continue;
      removalTargets.add(math.Point(col, row));
    }
    _queueFateRemoval(removalTargets, FateRemovalEffectType.devilBlockBreak);
  }

  void _updatePreviewClearState() {
    if (!_isDraggingBlock) {
      _previewClearResult = PreviewClearResult.empty;
      return;
    }
    if (_isSelectedDestructionBlock) {
      _previewClearResult = PreviewClearResult.empty;
      return;
    }

    final selectedShape = _draggingShape;
    final screenPosition = _dragScreenPosition;
    if (selectedShape == null || screenPosition == null) {
      _previewClearResult = PreviewClearResult.empty;
      return;
    }

    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) {
      _previewClearResult = PreviewClearResult.empty;
      return;
    }

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) {
      _previewClearResult = PreviewClearResult.empty;
      return;
    }

    _previewClearResult = LineClearSystem.getPreviewClearLines(
      board: board,
      shape: selectedShape,
      anchorRow: row,
      anchorCol: col,
      fillState: _currentFillState,
    );
  }
}
