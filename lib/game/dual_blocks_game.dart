import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/block_shape.dart';
import 'models/cell_state.dart';
import 'models/game_layout.dart';
import 'models/line_clear_result.dart';
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
  int? selectedTrayIndex;
  bool _isDraggingBlock = false;
  BlockShape? _draggingShape;
  Offset? _dragScreenPosition;
  LineClearResult _lastClearResult = const LineClearResult(
    fullRows: {},
    fullCols: {},
  );
  double _lineHighlightLeft = 0;
  final math.Random _random = math.Random();

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
    );
    if (placed) {
      score += selectedShape.cells.length;
      _applyLineClear();
      _consumeSelectedTrayBlock();
    }
    return placed;
  }

  void _applyLineClear() {
    final result = LineClearSystem.findFilledLines(board);
    if (!result.hasAny) return;

    _lastClearResult = result;
    _lineHighlightLeft = GameConstants.lineClearHighlightSeconds;

    final clearedCellCount = LineClearSystem.clearFilledLines(
      board: board,
      result: result,
    );
    score += clearedCellCount * GameConstants.lineClearPointPerCell;
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

    selectedTrayIndex = index;
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
    trayBlocks = HandGenerationSystem.generateHand(
      board,
      random: _random,
      blockPool: BlockCatalog.pool,
      handSize: GameConstants.traySlotCount,
    ).map<BlockShape?>((shape) => shape).toList(growable: false);
    selectedTrayIndex = trayBlocks.isNotEmpty ? 0 : null;
    if (increaseTurn) {
      turn += 1;
    }
    _evaluateGameOver();
  }

  void _evaluateGameOver() {
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

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isGameOver) {
      _startNewGame();
      return;
    }

    final screenPosition = Offset(
      event.localPosition.x,
      event.localPosition.y,
    );

    final selected = trySelectTrayFromScreen(screenPosition);
    if (selected) return;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isGameOver) return;

    final screenPosition = Offset(
      event.localPosition.x,
      event.localPosition.y,
    );

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
    if (_lineHighlightLeft <= 0) return;

    _lineHighlightLeft -= dt;
    if (_lineHighlightLeft <= 0) {
      _lineHighlightLeft = 0;
      _lastClearResult = const LineClearResult(fullRows: {}, fullCols: {});
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
      selectedTrayIndex: selectedTrayIndex,
      dragShape: _draggingShape,
      dragScreenPosition: _dragScreenPosition,
      dragCanPlace: _dragCanPlace,
      clearRows: _lastClearResult.fullRows,
      clearCols: _lastClearResult.fullCols,
      showClearHighlight: _lineHighlightLeft > 0,
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
}
