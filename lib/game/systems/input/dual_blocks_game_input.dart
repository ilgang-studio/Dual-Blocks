part of '../../dual_blocks_game.dart';

// Input helpers: coordinate mapping, drag logic, theme menu tap handling.
extension _GameInput on DualBlocksGame {
  math.Point<int>? screenToBoard(Offset p) => layout?.screenToBoard(p);

  bool _handleThemeTap(Offset screenPosition) {
    final currentLayout = layout;
    if (currentLayout == null) return false;

    final buttonRect = currentLayout.settingsButtonRect();
    if (buttonRect.contains(screenPosition)) {
      openSettingsModal();
      return true;
    }
    return false;
  }

  bool _tryPlaceFromDrag() {
    if (!_isDraggingBlock || _draggingShape == null) return false;
    final screenPosition = _dragScreenPosition;
    if (screenPosition == null) return false;
    if (_pendingFateRemovalCells.isNotEmpty) return false;

    final boardPoint = screenToBoard(screenPosition);
    if (boardPoint == null) return false;

    final col = boardPoint.x;
    final row = boardPoint.y;
    if (!canPlace(row, col)) return false;
    final placed = placeBlock(row, col);
    if (placed) _previewClearResult = PreviewClearResult.empty;
    return placed;
  }

  void _clearDragState() {
    _isDraggingBlock = false;
    _draggingShape = null;
    _dragScreenPosition = null;
    _previewClearResult = PreviewClearResult.empty;
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
    return canPlace(dragBoardPoint.y, dragBoardPoint.x);
  }
}
