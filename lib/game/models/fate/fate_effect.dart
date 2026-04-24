enum FateType { angel, devil }

enum DevilGiftType { devilOneByOne, devilDestroy }

enum FateRemovalEffectType { angelPurge, devilBlast, devilBlockBreak }

class FateDecision {
  const FateDecision({required this.type, required this.reason});

  final FateType type;
  final String reason;
}
