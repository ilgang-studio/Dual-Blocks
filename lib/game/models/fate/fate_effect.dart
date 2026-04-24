enum FateType { angel, devil }

enum DevilGiftType { seedOfRuin, destructionAid }

enum FateRemovalEffectType { angelPurge, devilBlast, devilBlockBreak }

class FateDecision {
  const FateDecision({required this.type, required this.reason});

  final FateType type;
  final String reason;
}
