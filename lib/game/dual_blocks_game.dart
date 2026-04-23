import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/block_shape.dart';
import 'models/cell_state.dart';
import 'models/fate_effect.dart';
import 'models/game_layout.dart';
import 'models/line_clear_result.dart';
import 'systems/alignment_turn_system.dart';
import 'systems/devil_block_system.dart';
import 'systems/fate_effect_system.dart';
import 'systems/game_flow_system.dart';
import 'systems/hand_generation_system.dart';
import 'systems/layout_system.dart';
import 'systems/line_clear_system.dart';
import 'systems/placement_system.dart';
import 'systems/score_system.dart';
import 'systems/turn_flow_system.dart';

class DualBlocksGame extends FlameGame with TapCallbacks, DragCallbacks {
  GameLayout? layout;
  int score = 0;
  int turn = 1;
  bool isGameOver = false;
  List<BlockShape?> trayBlocks = [];
  List<FateType?> trayFates = [];
  List<DevilGiftType?> trayDevilGifts = [];
  int? selectedTrayIndex;
  bool isAlignmentTurn = false;
  bool _alignmentChoicePending = false;
  bool _isDraggingBlock = false;
  BlockShape? _draggingShape;
  Offset? _dragScreenPosition;
  LineClearResult _lastClearResult = const LineClearResult(
    fullRows: {},
    fullCols: {},
  );
  LineClearResult? _pendingClearResult;
  double _lineHighlightLeft = 0;
  double _scorePopupLeft = 0;
  int _scorePopupValue = 0;
  double _placeSuccessLeft = 0;
  double _placeFailLeft = 0;
  final List<math.Point<int>> _pendingFateRemovalCells = [];
  FateType? _pendingFateRemovalType;
  double _fateRemovalLeft = 0;
  final math.Random _random = math.Random();
  int _angelStack = 0;
  int _devilStack = 0;
  int _storedScore = 0;
  int _comboCount = 0;
  double _nextClearScoreMultiplier = 1.0;
  bool _angelEasyHandBoostPending = false;
  DevilGiftType? _pendingDevilGift;
  DevilGiftType? _selectedDevilGift;
  double _effectTime = 0;
  FateType? _selectedFate;
  FateType? _activeFateType;
  String? _activeFateReason;
  double _fateBannerLeft = 0;
  final AlignmentTurnSystem _alignmentTurnSystem = AlignmentTurnSystem();

  final List<List<CellState>> board = List.generate(
    GameConstants.boardSize,
    (_) => List.generate(GameConstants.boardSize, (_) => CellState.empty),
  );

  bool canPlace(int row, int col) {
    if (_pendingClearResult != null) return false;
    if (_pendingFateRemovalCells.isNotEmpty) return false;
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
      score += selectedShape.cells.length;
      _applyLineClear();
      _consumeSelectedTrayBlock();
    } else {
      _triggerPlaceFailFeedback();
    }
    return placed;
  }

  int _applyLineClear() {
    final result = LineClearSystem.findFilledLines(board);
    if (!result.hasAny) {
      _comboCount = 0;
      return 0;
    }

    _lastClearResult = result;
    _lineHighlightLeft = GameConstants.lineClearHighlightSeconds;
    _pendingClearResult = result;
    final clearedCellCountEstimate = ScoreSystem.estimateClearedCellCount(
      result,
    );
    final clearedLineCount = result.fullRows.length + result.fullCols.length;
    final clearScore = ScoreSystem.calculateLineClearScore(
      comboCount: _comboCount,
      clearedLineCount: clearedLineCount,
    );
    _comboCount += 1;

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
    _scorePopupValue = scoreResult.grantedScore;
    _scorePopupLeft = GameConstants.scorePopupSeconds;
    return clearedCellCountEstimate;
  }

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
    _storedScore = 0;

    var effectSummary = '';
    switch (GameConstants.angelEffectMode) {
      case AngelEffectMode.rescueCleanup:
        final removed = _rescueCleanup();
        effectSummary = 'Rescue cleanup removed $removed cell';
        break;
      case AngelEffectMode.scoreShield:
        _nextClearScoreMultiplier = GameConstants.angelNextClearScoreMultiplier;
        effectSummary =
            'Next clear score x${GameConstants.angelNextClearScoreMultiplier.toStringAsFixed(1)}';
        break;
      case AngelEffectMode.handRefine:
        _angelEasyHandBoostPending = true;
        effectSummary = 'Next normal hand refined to easier blocks';
        break;
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
    _queueFateRemoval([target], FateType.angel);
    return 1;
  }

  math.Point<int>? screenToBoard(Offset p) {
    final currentLayout = layout;
    if (currentLayout == null) return null;
    return currentLayout.screenToBoard(p);
  }

  void tryPlaceFromScreen(Offset screenPosition) {
    if (_pendingClearResult != null) return;
    if (_pendingFateRemovalCells.isNotEmpty) return;
    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) {
      _triggerPlaceFailFeedback();
      return;
    }
    placeBlock(row, col);
  }

  bool _tryPlaceFromDrag() {
    final draggingShape = _draggingShape;
    final screenPosition = _dragScreenPosition;
    if (!_isDraggingBlock || draggingShape == null || screenPosition == null) {
      return false;
    }
    if (_pendingFateRemovalCells.isNotEmpty) return false;

    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return false;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) {
      _triggerPlaceFailFeedback();
      return false;
    }
    return placeBlock(row, col);
  }

  bool trySelectTrayFromScreen(Offset screenPosition) {
    if (isGameOver) return false;
    if (_pendingClearResult != null) return false;
    if (_pendingFateRemovalCells.isNotEmpty) return false;
    final currentLayout = layout;
    if (currentLayout == null) return false;

    final index = currentLayout.screenToTrayIndex(screenPosition);
    if (index == null) return false;
    if (index >= trayBlocks.length) return false;
    if (trayBlocks[index] == null) return false;

    if (_alignmentChoicePending) {
      _applyAlignmentChoice(index);
      return true;
    }

    selectedTrayIndex = index;
    _selectedFate = trayFates[index];
    return true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layout = LayoutSystem.calculate(size);
    _startNewGame();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    layout = LayoutSystem.calculate(size);
  }

  void _startNewGame() {
    _clearBoard();
    score = 0;
    turn = 1;
    isGameOver = false;
    _angelStack = 0;
    _devilStack = 0;
    _storedScore = 0;
    _comboCount = 0;
    _nextClearScoreMultiplier = 1.0;
    _angelEasyHandBoostPending = false;
    _pendingDevilGift = null;
    _selectedDevilGift = null;
    _effectTime = 0;
    _activeFateType = null;
    _activeFateReason = null;
    _fateBannerLeft = 0;
    _alignmentTurnSystem.turnCounter = 1;
    _refillTray(increaseTurn: false);
  }

  void _clearBoard() {
    for (var row = 0; row < board.length; row++) {
      for (var col = 0; col < board[row].length; col++) {
        board[row][col] = CellState.empty;
      }
    }
    _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
    _lineHighlightLeft = 0;
    _pendingClearResult = null;
    _pendingFateRemovalCells.clear();
    _pendingFateRemovalType = null;
    _fateRemovalLeft = 0;
    _scorePopupLeft = 0;
    _scorePopupValue = 0;
    _placeSuccessLeft = 0;
    _placeFailLeft = 0;
  }

  void _refillTray({required bool increaseTurn}) {
    isAlignmentTurn = _alignmentTurnSystem.shouldStartAlignmentTurn();
    if (isAlignmentTurn) {
      _buildAlignmentTray();
    } else {
      _buildNormalTray();
    }

    if (increaseTurn) {
      turn += 1;
    }
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
    if (isGameOver) {
      _clearDragState();
    }
  }

  BlockShape? get _selectedShape {
    final index = selectedTrayIndex;
    if (index == null) return null;
    if (index < 0 || index >= trayBlocks.length) return null;
    return trayBlocks[index];
  }

  void _consumeSelectedTrayBlock() {
    final index = selectedTrayIndex;
    if (index == null) return;
    if (index < 0 || index >= trayBlocks.length) return;

    trayBlocks[index] = null;

    selectedTrayIndex = TurnFlowSystem.nextSelectedIndex(trayBlocks);
    if (TurnFlowSystem.shouldRefillTray(trayBlocks)) {
      _refillTray(increaseTurn: true);
      return;
    }
    _evaluateGameOver();
  }

  void _buildNormalTray() {
    final useAngelHandRefine = _angelEasyHandBoostPending;
    trayBlocks = HandGenerationSystem.generateHand(
      board,
      random: _random,
      blockPool: BlockCatalog.pool,
      handSize: GameConstants.traySlotCount,
      weightResolver: useAngelHandRefine ? _angelRefinedWeight : null,
    ).map<BlockShape?>((shape) => shape).toList(growable: false);
    _angelEasyHandBoostPending = false;
    _applyPendingDevilGift();

    trayFates = List<FateType?>.filled(GameConstants.traySlotCount, null);
    trayDevilGifts = List<DevilGiftType?>.filled(
      GameConstants.traySlotCount,
      null,
    );
    selectedTrayIndex = trayBlocks.isNotEmpty ? 0 : null;
    _selectedFate = selectedTrayIndex == null
        ? null
        : trayFates[selectedTrayIndex!];
    _alignmentChoicePending = false;
  }

  double _angelRefinedWeight(BlockShape shape) {
    final multiplier = _isEasyShape(shape)
        ? GameConstants.angelEasyWeightMultiplier
        : GameConstants.angelHardWeightMultiplier;
    return shape.weight * multiplier;
  }

  bool _isEasyShape(BlockShape shape) {
    return shape.cells.length <= 3;
  }

  void _applyPendingDevilGift() {
    final pendingGift = _pendingDevilGift;
    if (pendingGift == null) return;
    if (trayBlocks.isEmpty) {
      _pendingDevilGift = null;
      return;
    }

    final replaceIndex = _random.nextInt(trayBlocks.length);
    if (pendingGift == DevilGiftType.greedBestBlock) {
      final best = DevilBlockSystem.findBestBlock(
        board: board,
        blockPool: BlockCatalog.pool,
      );
      if (best != null) {
        trayBlocks[replaceIndex] = best;
      }
    } else {
      final aid = DevilBlockSystem.pickDestructionAidBlock(
        board: board,
        blockPool: BlockCatalog.pool,
      );
      if (aid != null) {
        trayBlocks[replaceIndex] = aid;
      }
    }

    _pendingDevilGift = null;
  }

  void _buildAlignmentTray() {
    final normal = _pickPlaceableRandomShape();
    final angel = _pickPlaceableRandomShape();
    final devil = _pickPlaceableRandomShape();

    trayBlocks = <BlockShape?>[normal, angel, devil];
    trayFates = <FateType?>[null, FateType.angel, FateType.devil];
    trayDevilGifts = <DevilGiftType?>[
      null,
      null,
      _random.nextBool()
          ? DevilGiftType.greedBestBlock
          : DevilGiftType.destructionAid,
    ];
    selectedTrayIndex = null;
    _selectedFate = null;
    _selectedDevilGift = null;
    _alignmentChoicePending = true;
  }

  BlockShape _pickPlaceableRandomShape() {
    final placeable = BlockCatalog.pool
        .where((shape) => HandGenerationSystem.canPlaceAnywhere(board, shape))
        .toList(growable: false);
    final source = placeable.isNotEmpty ? placeable : BlockCatalog.pool;
    return source[_random.nextInt(source.length)];
  }

  void _applyAlignmentChoice(int index) {
    final chosenBlock = trayBlocks[index];
    final chosenFate = trayFates[index];
    final chosenDevilGift = index < trayDevilGifts.length
        ? trayDevilGifts[index]
        : null;
    if (chosenBlock == null) return;

    for (var i = 0; i < trayBlocks.length; i++) {
      if (i == index) continue;
      trayBlocks[i] = null;
    }
    selectedTrayIndex = index;
    _selectedFate = chosenFate;
    _selectedDevilGift = chosenFate == FateType.devil ? chosenDevilGift : null;
    _alignmentChoicePending = false;
    isAlignmentTurn = false;

    if (chosenFate == FateType.angel) {
      selectAngel();
    } else if (chosenFate == FateType.devil) {
      selectDevil();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isGameOver) {
      _startNewGame();
      return;
    }

    final screenPosition = Offset(event.localPosition.x, event.localPosition.y);
    final selected = trySelectTrayFromScreen(screenPosition);
    if (selected) return;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isGameOver) return;
    if (_pendingClearResult != null) return;
    if (_pendingFateRemovalCells.isNotEmpty) return;

    final screenPosition = Offset(event.localPosition.x, event.localPosition.y);
    final selected = trySelectTrayFromScreen(screenPosition);
    if (!selected) return;

    _isDraggingBlock = true;
    _draggingShape = _selectedShape;
    _dragScreenPosition = screenPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isGameOver) return;
    if (!_isDraggingBlock) return;

    _dragScreenPosition = Offset(
      event.canvasEndPosition.x,
      event.canvasEndPosition.y,
    );
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isGameOver) {
      _clearDragState();
      return;
    }
    _tryPlaceFromDrag();
    _clearDragState();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _clearDragState();
  }

  void _clearDragState() {
    _isDraggingBlock = false;
    _draggingShape = null;
    _dragScreenPosition = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _effectTime += dt;
    if (_pendingFateRemovalCells.isNotEmpty && _fateRemovalLeft > 0) {
      _fateRemovalLeft -= dt;
      if (_fateRemovalLeft <= 0) {
        _resolvePendingFateRemoval();
      }
    }

    if (_pendingClearResult != null && _lineHighlightLeft > 0) {
      _lineHighlightLeft -= dt;
      if (_lineHighlightLeft <= 0) {
        _resolvePendingLineClear();
      }
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final currentLayout = layout;
    if (currentLayout == null) return;

    DualBlocksRenderer.render(
      canvas: canvas,
      layout: currentLayout,
      score: score,
      turn: turn,
      isGameOver: isGameOver,
      board: board,
      trayBlocks: trayBlocks,
      trayFates: trayFates,
      trayDevilGifts: trayDevilGifts,
      selectedTrayIndex: selectedTrayIndex,
      isAlignmentTurn: isAlignmentTurn,
      alignmentChoicePending: _alignmentChoicePending,
      effectTime: _effectTime,
      dragShape: _draggingShape,
      dragScreenPosition: _dragScreenPosition,
      dragCanPlace: _dragCanPlace,
      clearRows: _lastClearResult.fullRows,
      clearCols: _lastClearResult.fullCols,
      showClearHighlight: _lineHighlightLeft > 0,
      fateRemovalCells: _pendingFateRemovalCells,
      fateRemovalType: _pendingFateRemovalType,
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
      placeSuccessProgress:
          _placeSuccessLeft / GameConstants.placementSuccessSeconds,
      placeFailProgress: _placeFailLeft / GameConstants.placementFailSeconds,
    );
  }

  math.Point<int>? get _dragBoardPoint {
    final screenPosition = _dragScreenPosition;
    if (screenPosition == null) return null;
    return screenToBoard(screenPosition);
  }

  bool get _dragCanPlace {
    if (isGameOver) return false;
    final dragBoardPoint = _dragBoardPoint;
    if (dragBoardPoint == null) return false;
    final row = dragBoardPoint.y;
    final col = dragBoardPoint.x;
    return canPlace(row, col);
  }

  CellState get _currentFillState {
    if (_selectedFate == FateType.angel) return CellState.angelFilled;
    if (_selectedFate == FateType.devil) return CellState.devilFilled;
    return CellState.filled;
  }

  int get angelStack => _angelStack;
  int get devilStack => _devilStack;
  int get storedScore => _storedScore;

  void _queueFateRemoval(List<math.Point<int>> cells, FateType type) {
    if (cells.isEmpty) return;
    _pendingFateRemovalCells
      ..clear()
      ..addAll(cells);
    _pendingFateRemovalType = type;
    _fateRemovalLeft = GameConstants.fateRemovalEffectSeconds;
  }

  int _queueDevilDestructionRemoval(int targetCount) {
    final picked = FateEffectSystem.pickDestructionCells(
      board: board,
      random: _random,
      targetCount: targetCount,
    );
    if (picked.isEmpty) return 0;
    _queueFateRemoval(picked, FateType.devil);
    return picked.length;
  }

  void _resolvePendingLineClear() {
    final pending = _pendingClearResult;
    if (pending == null) return;

    LineClearSystem.clearFilledLines(board: board, result: pending);

    _pendingClearResult = null;
    _lineHighlightLeft = 0;
    _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
    _evaluateGameOver();
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
    }
    _pendingFateRemovalCells.clear();
    _pendingFateRemovalType = null;
    _fateRemovalLeft = 0;
    _evaluateGameOver();
  }

  void _triggerPlaceFailFeedback() {
    // Placement fail flash disabled by request.
  }
}
