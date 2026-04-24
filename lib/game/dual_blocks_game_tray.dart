part of 'dual_blocks_game.dart';

// Tray management: building hands, alignment tray, selection, consumption.
extension _GameTray on DualBlocksGame {
  BlockShape? get _selectedShape {
    final index = selectedTrayIndex;
    if (index == null) return null;
    if (index < 0 || index >= trayBlocks.length) return null;
    return trayBlocks[index];
  }

  int? get _selectedTrayBlockColorIndex {
    final index = selectedTrayIndex;
    if (index == null) return null;
    if (index < 0 || index >= trayBlockColorIndices.length) return null;
    return trayBlockColorIndices[index];
  }

  DevilGiftType? get _selectedTrayDevilGift {
    final index = selectedTrayIndex;
    if (index == null) return null;
    if (index < 0 || index >= trayDevilGifts.length) return null;
    return trayDevilGifts[index];
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

  void _buildNormalTray() {
    final useAngelHandRefine = _angelEasyHandBoostPending;
    final basePool = _guaranteeOneByOneNextTurn
        ? BlockCatalog.pool
              .where((shape) => shape.id != BlockCatalog.single.id)
              .toList(growable: false)
        : BlockCatalog.pool;
    final handSize = _guaranteeOneByOneNextTurn
        ? GameConstants.traySlotCount - 1
        : GameConstants.traySlotCount;

    final generated = HandGenerationSystem.generateHand(
      board,
      random: _random,
      blockPool: basePool,
      handSize: handSize,
      weightResolver: useAngelHandRefine ? _angelRefinedWeight : null,
    );

    if (_guaranteeOneByOneNextTurn) {
      trayBlocks = <BlockShape?>[BlockCatalog.single, ...generated];
      _guaranteeOneByOneNextTurn = false;
    } else {
      trayBlocks = generated
          .map<BlockShape?>((shape) => shape)
          .toList(growable: false);
    }
    _angelEasyHandBoostPending = false;
    trayBlockColorIndices = List<int?>.generate(
      trayBlocks.length,
      (_) => _nextRainbowColorIndex(),
      growable: false,
    );
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

  void _buildAlignmentTray() {
    final normal = _pickPlaceableRandomShape();
    final angel = _pickPlaceableRandomShape();
    final devil = _pickPlaceableRandomShape();

    trayBlocks = <BlockShape?>[normal, angel, devil];
    trayBlockColorIndices = <int?>[_nextRainbowColorIndex(), null, null];
    trayFates = <FateType?>[null, FateType.angel, FateType.devil];
    trayDevilGifts = <DevilGiftType?>[
      null,
      null,
      _random.nextBool()
          ? DevilGiftType.seedOfRuin
          : DevilGiftType.destructionAid,
    ];
    selectedTrayIndex = null;
    _selectedFate = null;
    _selectedDevilGift = null;
    _alignmentChoicePending = true;
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
      if (i < trayBlockColorIndices.length) trayBlockColorIndices[i] = null;
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

  void _consumeSelectedTrayBlock() {
    final index = selectedTrayIndex;
    if (index == null) return;
    if (index < 0 || index >= trayBlocks.length) return;

    trayBlocks[index] = null;
    if (index < trayBlockColorIndices.length) {
      trayBlockColorIndices[index] = null;
    }
    if (index < trayFates.length) trayFates[index] = null;
    if (index < trayDevilGifts.length) trayDevilGifts[index] = null;
    _selectedDevilGift = null;

    selectedTrayIndex = TurnFlowSystem.nextSelectedIndex(trayBlocks);
    if (TurnFlowSystem.shouldRefillTray(trayBlocks)) {
      _refillTray(increaseTurn: true);
      return;
    }
    _evaluateGameOver();
  }

  BlockShape _pickPlaceableRandomShape() {
    final placeable = BlockCatalog.pool
        .where((shape) => HandGenerationSystem.canPlaceAnywhere(board, shape))
        .toList(growable: false);
    final source = placeable.isNotEmpty ? placeable : BlockCatalog.pool;
    return source[_random.nextInt(source.length)];
  }

  double _angelRefinedWeight(BlockShape shape) {
    final multiplier = _isEasyShape(shape)
        ? GameConstants.angelEasyWeightMultiplier
        : GameConstants.angelHardWeightMultiplier;
    return shape.weight * multiplier;
  }

  bool _isEasyShape(BlockShape shape) => shape.cells.length <= 3;

  void _injectOneByOneIntoCurrentTray() {
    if (trayBlocks.isEmpty) return;

    int targetIndex = trayBlocks.indexWhere((shape) => shape == null);
    if (targetIndex == -1) {
      targetIndex = selectedTrayIndex ?? 0;
      targetIndex = targetIndex.clamp(0, trayBlocks.length - 1);
    }

    trayBlocks[targetIndex] = BlockCatalog.single;
    if (targetIndex < trayBlockColorIndices.length) {
      trayBlockColorIndices[targetIndex] = _nextRainbowColorIndex();
    }
    if (targetIndex < trayFates.length) {
      trayFates[targetIndex] = FateType.devil;
    }
    if (targetIndex < trayDevilGifts.length) {
      trayDevilGifts[targetIndex] = DevilGiftType.seedOfRuin;
    }

    selectedTrayIndex = targetIndex;
    _selectedFate = FateType.devil;
    _selectedDevilGift = DevilGiftType.seedOfRuin;
  }
}
