import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/block_shape.dart';
import 'models/block_theme_mode.dart';
import 'models/cell_state.dart';
import 'models/fate_effect.dart';
import 'models/game_layout.dart';
import 'models/line_clear_result.dart';
import 'models/preview_clear_result.dart';
import 'models/render_frame_data.dart';
import 'systems/alignment_turn_system.dart';
import 'systems/fate_effect_system.dart';
import 'systems/game_flow_system.dart';
import 'systems/hand_generation_system.dart';
import 'systems/layout_system.dart';
import 'systems/line_clear_system.dart';
import 'systems/placement_system.dart';
import 'systems/score_system.dart';
import 'systems/turn_flow_system.dart';

part 'dual_blocks_game_lifecycle.dart';
part 'dual_blocks_game_tray.dart';
part 'dual_blocks_game_placement.dart';
part 'dual_blocks_game_fate.dart';
part 'dual_blocks_game_score.dart';
part 'dual_blocks_game_input.dart';

class DualBlocksGame extends FlameGame with TapCallbacks, DragCallbacks {
  static const int _rainbowPaletteCount = 7;

  // ── Game state ───────────────────────────────────────────────────────────────
  GameLayout? layout;
  int score = 0;
  int turn = 1;
  bool isGameOver = false;

  // ── Tray state ───────────────────────────────────────────────────────────────
  List<BlockShape?> trayBlocks = [];
  List<int?> trayBlockColorIndices = [];
  List<FateType?> trayFates = [];
  List<DevilGiftType?> trayDevilGifts = [];
  int? selectedTrayIndex;
  bool isAlignmentTurn = false;
  bool _alignmentChoicePending = false;

  // ── Drag state ───────────────────────────────────────────────────────────────
  bool _isDraggingBlock = false;
  BlockShape? _draggingShape;
  Offset? _dragScreenPosition;
  PreviewClearResult _previewClearResult = PreviewClearResult.empty;

  // ── Line-clear state ─────────────────────────────────────────────────────────
  LineClearResult _lastClearResult = const LineClearResult(
    fullRows: {},
    fullCols: {},
  );
  LineClearResult? _pendingClearResult;
  double _lineHighlightLeft = 0;

  // ── UI feedback timers ───────────────────────────────────────────────────────
  double _scorePopupLeft = 0;
  int _scorePopupValue = 0;
  double _scorePulseLeft = 0;
  double _placeSuccessLeft = 0;
  double _placeFailLeft = 0;

  // ── Fate removal state ───────────────────────────────────────────────────────
  final List<math.Point<int>> _pendingFateRemovalCells = [];
  FateRemovalEffectType? _pendingFateRemovalEffectType;
  double _fateRemovalLeft = 0;

  // ── Fate / angel / devil state ───────────────────────────────────────────────
  final math.Random _random = math.Random();
  int _angelStack = 0;
  int _devilStack = 0;
  int _storedScore = 0;
  int _comboCount = 0;
  int _comboMissStreak = 0;
  double _nextClearScoreMultiplier = 1.0;
  bool _angelEasyHandBoostPending = false;
  bool _guaranteeOneByOneNextTurn = false;
  DevilGiftType? _selectedDevilGift;
  FateType? _selectedFate;
  FateType? _activeFateType;
  String? _activeFateReason;
  double _fateBannerLeft = 0;

  // ── Score display animation ──────────────────────────────────────────────────
  int _bestScore = 0;
  double _displayScore = 0;
  double _displayScoreStart = 0;
  int _displayScoreTarget = 0;
  double _displayScoreAnimElapsed = 0;
  double _displayScoreAnimDuration = 0;

  // ── Effects / theme ──────────────────────────────────────────────────────────
  double _effectTime = 0;
  BlockThemeMode _themeMode = BlockThemeMode.solid;
  Color _customThemeColor = const Color(0xFFF59E0B);
  String _selectedLanguage = 'English';
  bool _showThemeMenu = false;
  final ValueNotifier<bool> settingsModalVisible = ValueNotifier<bool>(false);

  // ── Systems ──────────────────────────────────────────────────────────────────
  final AlignmentTurnSystem _alignmentTurnSystem = AlignmentTurnSystem();

  // ── Board ────────────────────────────────────────────────────────────────────
  final List<List<CellState>> board = List.generate(
    GameConstants.boardSize,
    (_) => List.generate(GameConstants.boardSize, (_) => CellState.empty),
  );
  final List<List<int?>> _boardColorIndices = List.generate(
    GameConstants.boardSize,
    (_) => List<int?>.filled(GameConstants.boardSize, null),
  );

  // ── FlameGame overrides ──────────────────────────────────────────────────────

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

  @override
  void onRemove() {
    settingsModalVisible.dispose();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isGameOver) {
      _startNewGame();
      return;
    }
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (_handleThemeTap(pos)) return;
    trySelectTrayFromScreen(pos);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
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

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isGameOver) return;
    if (!_isDraggingBlock) return;

    _dragScreenPosition = Offset(
      event.canvasEndPosition.x,
      event.canvasEndPosition.y,
    );
    _updatePreviewClearState();
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

  // ── Settings API (Flutter modal bridge) ────────────────────────────────────
  BlockThemeMode get selectedThemeMode => _themeMode;
  Color get selectedCustomThemeColor => _customThemeColor;
  String get selectedLanguage => _selectedLanguage;

  void openSettingsModal() {
    _showThemeMenu = true;
    settingsModalVisible.value = true;
  }

  void closeSettingsModal() {
    _showThemeMenu = false;
    settingsModalVisible.value = false;
  }

  void setThemeMode(BlockThemeMode mode) {
    _themeMode = mode;
  }

  void setCustomThemeColor(Color color) {
    _customThemeColor = color;
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
  }

  void restartFromSettings() {
    closeSettingsModal();
    _startNewGame();
  }

  int _nextRainbowColorIndex() => _random.nextInt(_rainbowPaletteCount);
}
