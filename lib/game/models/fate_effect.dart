enum FateType { angel, devil }

enum DevilGiftType { greedBestBlock, destructionAid }

class FateDecision {
  const FateDecision({required this.type, required this.reason});

  final FateType type;
  final String reason;
}
