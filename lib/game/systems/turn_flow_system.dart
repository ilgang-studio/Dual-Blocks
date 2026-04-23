import '../models/block_shape.dart';

class TurnFlowSystem {
  static int? nextSelectedIndex(List<BlockShape?> trayBlocks) {
    final next = trayBlocks.indexWhere((shape) => shape != null);
    return next == -1 ? null : next;
  }

  static bool shouldRefillTray(List<BlockShape?> trayBlocks) {
    return nextSelectedIndex(trayBlocks) == null;
  }
}
