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
import 'systems/game_flow_system.dart';
import 'systems/hand_generation_system.dart';
import 'systems/layout_system.dart';
import 'systems/line_clear_system.dart';
import 'systems/placement_system.dart';

class DualBlocksGame extends FlameGame with TapCallbacks, DragCallbacks {
  GameLayout? layout;
  int score = 0;
  int turn = 1;
  bool isGameOver = false;
  List<BlockShape?> trayBlocks = [];
  List<FateType?> trayFates = [];
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
  double _lineHighlightLeft = 0;
  final math.Random _random = math.Random();
  int _angelStack = 0;
  int _devilStack = 0;
  int _storedScore = 0;
  double _nextClearScoreMultiplier = 1.0;
  bool _angelEasyHandBoostPending = false;
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
    }
    return placed;
  }

  int _applyLineClear() {
    final result = LineClearSystem.findFilledLines(board);
    if (!result.hasAny) return 0;

    _lastClearResult = result;
    _lineHighlightLeft = GameConstants.lineClearHighlightSeconds;

    final clearedCellCount = LineClearSystem.clearFilledLines(
      board: board,
      result: result,
    );
    final clearScore = clearedCellCount * GameConstants.lineClearPointPerCell;
    var scoredClear = clearScore;
    if (_nextClearScoreMultiplier > 1.0) {
      scoredClear = (clearScore * _nextClearScoreMultiplier).round();
      _nextClearScoreMultiplier = 1.0;
    }
    if (_angelStack > 0) {
      final stored = (scoredClear * GameConstants.angelStoreRatio).floor();
      _storedScore += stored;
      score += scoredClear - stored;
    } else {
      score += scoredClear;
    }
    return clearedCellCount;
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
    _clearRandomLine();
    score = (score * (1 - GameConstants.devilScorePenaltyRatio)).toInt();
    _showFateBanner(FateType.devil, 'Random line clear, -10% score');
    debugPrint('[Devil Triggered] -10%');
    _evaluateGameOver();
  }

  void _showFateBanner(FateType type, String reason) {
    _activeFateType = type;
    _activeFateReason = reason;
    _fateBannerLeft = GameConstants.fateBannerSeconds;
  }

  int _rescueCleanup() {
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
    if (target == null) return 0;

    if (target.axis == _LineAxis.row) {
      final row = target.index;
      final occupiedCols = <int>[];
      for (var col = 0; col < GameConstants.boardSize; col++) {
        if (board[row][col].isOccupied) occupiedCols.add(col);
      }
      if (occupiedCols.isEmpty) return 0;
      final col = occupiedCols[_random.nextInt(occupiedCols.length)];
      board[row][col] = CellState.empty;
      return 1;
    }

    final col = target.index;
    final occupiedRows = <int>[];
    for (var row = 0; row < GameConstants.boardSize; row++) {
      if (board[row][col].isOccupied) occupiedRows.add(row);
    }
    if (occupiedRows.isEmpty) return 0;
    final row = occupiedRows[_random.nextInt(occupiedRows.length)];
    board[row][col] = CellState.empty;
    return 1;
  }

  void _clearRandomLine() {
    final rowCount = board.length;
    if (rowCount == 0) return;
    final colCount = board.first.length;
    final clearRow = _random.nextBool();

    if (clearRow) {
      final row = _random.nextInt(rowCount);
      for (var col = 0; col < colCount; col++) {
        board[row][col] = CellState.empty;
      }
      return;
    }

    final col = _random.nextInt(colCount);
    for (var row = 0; row < rowCount; row++) {
      board[row][col] = CellState.empty;
    }
  }

  math.Point<int>? screenToBoard(Offset p) {
    final currentLayout = layout;
    if (currentLayout == null) return null;
    return currentLayout.screenToBoard(p);
  }

  void tryPlaceFromScreen(Offset screenPosition) {
    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) return;
    placeBlock(row, col);
  }

  bool _tryPlaceFromDrag() {
    final draggingShape = _draggingShape;
    final screenPosition = _dragScreenPosition;
    if (!_isDraggingBlock || draggingShape == null || screenPosition == null) {
      return false;
    }

    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return false;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) return false;
    return placeBlock(row, col);
  }

  bool trySelectTrayFromScreen(Offset screenPosition) {
    if (isGameOver) return false;
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
    _nextClearScoreMultiplier = 1.0;
    _angelEasyHandBoostPending = false;
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

    final next = trayBlocks.indexWhere((shape) => shape != null);
    selectedTrayIndex = next == -1 ? null : next;
    if (selectedTrayIndex == null) {
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
    trayFates = List<FateType?>.filled(GameConstants.traySlotCount, null);
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

  void _buildAlignmentTray() {
    final normal = _pickPlaceableRandomShape();
    final angel = _pickPlaceableRandomShape();
    final devil = _pickPlaceableRandomShape();

    trayBlocks = <BlockShape?>[normal, angel, devil];
    trayFates = <FateType?>[null, FateType.angel, FateType.devil];
    selectedTrayIndex = null;
    _selectedFate = null;
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
    if (chosenBlock == null) return;

    for (var i = 0; i < trayBlocks.length; i++) {
      if (i == index) continue;
      trayBlocks[i] = null;
    }
    selectedTrayIndex = index;
    _selectedFate = chosenFate;
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
    if (_lineHighlightLeft > 0) {
      _lineHighlightLeft -= dt;
      if (_lineHighlightLeft <= 0) {
        _lineHighlightLeft = 0;
        _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
      }
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
      selectedTrayIndex: selectedTrayIndex,
      isAlignmentTurn: isAlignmentTurn,
      alignmentChoicePending: _alignmentChoicePending,
      dragShape: _draggingShape,
      dragScreenPosition: _dragScreenPosition,
      dragCanPlace: _dragCanPlace,
      clearRows: _lastClearResult.fullRows,
      clearCols: _lastClearResult.fullCols,
      showClearHighlight: _lineHighlightLeft > 0,
      fateType: _activeFateType,
      fateReason: _activeFateReason,
      showFateBanner: _fateBannerLeft > 0,
      angelStack: _angelStack,
      devilStack: _devilStack,
      storedScore: _storedScore,
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
}

enum _LineAxis { row, col }

class _LineTarget {
  const _LineTarget._(this.axis, this.index);

  final _LineAxis axis;
  final int index;

  factory _LineTarget.row(int row) => _LineTarget._(_LineAxis.row, row);
  factory _LineTarget.col(int col) => _LineTarget._(_LineAxis.col, col);
}
