enum FateType {
  angel,
  devil,
}

class FateDecision {
  const FateDecision({
    required this.type,
    required this.reason,
  });

  final FateType type;
  final String reason;
}
