part of '../../dual_blocks_game.dart';

// Flame lifecycle and frame/runtime orchestration.
extension _GameRuntime on DualBlocksGame {
  void _handleOnLoad() {
    layout = LayoutSystem.calculate(size);
    _startNewGame();
  }

  void _handleOnGameResize(Vector2 size) {
    layout = LayoutSystem.calculate(size);
  }

  void _handleOnRemove() {
    settingsModalVisible.dispose();
  }

  void _handleUpdate(double dt) {
    _effectTime += dt;
    _updateDisplayedScore(dt);
    if (score > _bestScore) _bestScore = score;

    if (_pendingFateRemovalCells.isNotEmpty && _fateRemovalLeft > 0) {
      _fateRemovalLeft -= dt;
      if (_fateRemovalLeft <= 0) _resolvePendingFateRemoval();
    }

    if (_pendingClearResult != null && _lineHighlightLeft > 0) {
      _lineHighlightLeft -= dt;
      if (_lineHighlightLeft <= 0) _resolvePendingLineClear();
    } else if (_lineHighlightLeft > 0) {
      _lineHighlightLeft -= dt;
      if (_lineHighlightLeft <= 0) {
        _lineHighlightLeft = 0;
        _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
      }
    }

    if (_scorePopupLeft > 0) {
      _scorePopupLeft -= dt;
      if (_scorePopupLeft < 0) _scorePopupLeft = 0;
    }
    if (_scorePulseLeft > 0) {
      _scorePulseLeft -= dt;
      if (_scorePulseLeft < 0) _scorePulseLeft = 0;
    }
    if (_placeSuccessLeft > 0) {
      _placeSuccessLeft -= dt;
      if (_placeSuccessLeft < 0) _placeSuccessLeft = 0;
    }
    if (_placeFailLeft > 0) {
      _placeFailLeft -= dt;
      if (_placeFailLeft < 0) _placeFailLeft = 0;
    }
    if (_fateBannerLeft > 0) {
      _fateBannerLeft -= dt;
      if (_fateBannerLeft <= 0) {
        _fateBannerLeft = 0;
        _activeFateType = null;
        _activeFateReason = null;
      }
    }
  }

  void _handleRender(Canvas canvas) {
    final currentLayout = layout;
    if (currentLayout == null) return;

    DualBlocksRenderer.render(
      canvas: canvas,
      frame: RenderFrameData(
        layout: currentLayout,
        score: _visibleScore,
        bestScore: _bestScore,
        turn: turn,
        isGameOver: isGameOver,
        board: board,
        boardColorIndices: _boardColorIndices,
        trayBlocks: trayBlocks,
        trayBlockColorIndices: trayBlockColorIndices,
        trayFates: trayFates,
        trayDevilGifts: trayDevilGifts,
        selectedTrayIndex: selectedTrayIndex,
        isAlignmentTurn: isAlignmentTurn,
        alignmentChoicePending: _alignmentChoicePending,
        effectTime: _effectTime,
        themeMode: _themeMode,
        customThemeColor: _customThemeColor,
        showThemeMenu: _showThemeMenu,
        dragShape: _draggingShape,
        dragScreenPosition: _dragScreenPosition,
        dragCanPlace: _dragCanPlace,
        previewClearRows: _previewClearResult.rows,
        previewClearCols: _previewClearResult.cols,
        clearRows: _lastClearResult.fullRows,
        clearCols: _lastClearResult.fullCols,
        showClearHighlight: _lineHighlightLeft > 0,
        fateRemovalCells: _pendingFateRemovalCells,
        fateRemovalEffectType: _pendingFateRemovalEffectType,
        fateRemovalProgress:
            _fateRemovalLeft / GameConstants.fateRemovalEffectSeconds,
        fateType: _activeFateType,
        fateReason: _activeFateReason,
        showFateBanner: _fateBannerLeft > 0,
        angelStack: _angelStack,
        devilStack: _devilStack,
        storedScore: _storedScore,
        comboCount: _comboCount,
        scorePopupValue: _scorePopupValue,
        scorePopupProgress: _scorePopupLeft / GameConstants.scorePopupSeconds,
        scorePulseProgress: _scorePulseLeft / GameConstants.scorePulseSeconds,
        placeSuccessProgress:
            _placeSuccessLeft / GameConstants.placementSuccessSeconds,
        placeFailProgress: _placeFailLeft / GameConstants.placementFailSeconds,
        language: _selectedLanguage,
      ),
    );
  }

  void _handleOnTapDown(TapDownEvent event) {
    if (isGameOver) {
      _startNewGame();
      return;
    }
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (_handleThemeTap(pos)) return;
    trySelectTrayFromScreen(pos);
  }

  void _handleOnDragStart(DragStartEvent event) {
    if (isGameOver) return;
    if (_showThemeMenu) return;
    if (_pendingClearResult != null) return;
    if (_pendingFateRemovalCells.isNotEmpty) return;

    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (!trySelectTrayFromScreen(pos)) return;

    _isDraggingBlock = true;
    _draggingShape = _selectedShape;
    _dragScreenPosition = pos;
    _updatePreviewClearState();
  }

  void _handleOnDragUpdate(DragUpdateEvent event) {
    if (isGameOver) return;
    if (!_isDraggingBlock) return;

    _dragScreenPosition = Offset(
      event.canvasEndPosition.x,
      event.canvasEndPosition.y,
    );
    _updatePreviewClearState();
  }

  void _handleOnDragEnd(DragEndEvent event) {
    if (isGameOver) {
      _clearDragState();
      return;
    }
    _tryPlaceFromDrag();
    _clearDragState();
  }

  void _handleOnDragCancel(DragCancelEvent event) {
    _clearDragState();
  }
}
