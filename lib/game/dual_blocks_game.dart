import 'dart:math' as math;
import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import 'rendering/dual_blocks_renderer.dart';
import 'config/game_constants.dart';
import 'models/block/block_shape.dart';
import 'models/ui/block_theme_mode.dart';
import 'models/board/cell_state.dart';
import 'models/fate/fate_effect.dart';
import 'models/ui/game_layout.dart';
import 'models/board/line_clear_result.dart';
import 'models/board/preview_clear_result.dart';
import 'models/ui/render_frame_data.dart';
import 'localization/game_localization.dart';
import 'systems/turn/alignment_turn_system.dart';
import 'systems/fate/fate_effect_system.dart';
import 'systems/turn/game_flow_system.dart';
import 'systems/hand/hand_generation_system.dart';
import 'systems/input/layout_system.dart';
import 'systems/board/line_clear_system.dart';
import 'systems/board/placement_system.dart';
import 'systems/score/score_system.dart';
import 'systems/turn/turn_flow_system.dart';

part 'systems/turn/dual_blocks_game_lifecycle.dart';
part 'systems/hand/dual_blocks_game_tray.dart';
part 'systems/board/dual_blocks_game_placement.dart';
part 'systems/fate/dual_blocks_game_fate.dart';
part 'systems/score/dual_blocks_game_score.dart';
part 'systems/input/dual_blocks_game_input.dart';
part 'systems/core/dual_blocks_game_runtime.dart';

class DualBlocksGame extends FlameGame with TapCallbacks, DragCallbacks {
  static const int _rainbowPaletteCount = 7;
  static const double _devilToAngelSwitchPenaltyRatio = 0.08;

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
  bool _comboShieldActive = false;
  int _comboShieldArmedTurn = 0;
  bool _didClearLineThisTurn = false;
  FateType? _lastFateSelection;
  int _storedScore = 0;
  int _comboCount = 0;
  int _comboGraceMissesLeft = 0;
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
  String _selectedLanguage = GameLocalization.english;
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _handleOnLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _handleOnGameResize(size);
  }

  @override
  void onRemove() {
    _handleOnRemove();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _handleUpdate(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _handleRender(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _handleOnTapDown(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _handleOnDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _handleOnDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _handleOnDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _handleOnDragCancel(event);
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
    unawaited(_persistSettings());
  }

  void setCustomThemeColor(Color color) {
    _customThemeColor = color;
    unawaited(_persistSettings());
  }

  void setLanguage(String language) {
    if (!GameLocalization.supportedLanguages.contains(language)) return;
    _selectedLanguage = language;
    unawaited(_persistSettings());
  }

  void restartFromSettings() {
    closeSettingsModal();
    _startNewGame();
  }

  int _nextRainbowColorIndex() => _random.nextInt(_rainbowPaletteCount);

  void applyPersistedState(AppPrefsState state) {
    _bestScore = state.bestScore;
    _themeMode = state.themeMode;
    _customThemeColor = state.customThemeColor;
    if (GameLocalization.supportedLanguages.contains(state.language)) {
      _selectedLanguage = state.language;
    }
  }

  Future<void> _persistSettings() {
    return AppPrefs.saveSettings(
      themeMode: _themeMode,
      customThemeColor: _customThemeColor,
      language: _selectedLanguage,
    );
  }
}
