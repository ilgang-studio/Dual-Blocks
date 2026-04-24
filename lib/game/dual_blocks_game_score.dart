part of 'dual_blocks_game.dart';

// Score display: animated count-up, popup feedback.
extension _GameScore on DualBlocksGame {
  int get _visibleScore => _displayScore.round();

  void _showScoreGainFeedback(int gainedScore) {
    if (gainedScore <= 0) return;
    _scorePopupValue = gainedScore;
    _scorePopupLeft = GameConstants.scorePopupSeconds;
    _scorePulseLeft = GameConstants.scorePulseSeconds;
  }

  void _updateDisplayedScore(double dt) {
    if (_displayScoreTarget != score) _startScoreCountAnimation(score);

    if ((_displayScore - _displayScoreTarget).abs() < 0.001) {
      _displayScore = _displayScoreTarget.toDouble();
      return;
    }
    if (_displayScoreAnimDuration <= 0) {
      _displayScore = _displayScoreTarget.toDouble();
      return;
    }

    _displayScoreAnimElapsed += dt;
    final t = (_displayScoreAnimElapsed / _displayScoreAnimDuration).clamp(
      0.0,
      1.0,
    );
    final eased = Curves.easeOutCubic.transform(t);
    _displayScore =
        _displayScoreStart + ((_displayScoreTarget - _displayScoreStart) * eased);

    if (t >= 1.0) _displayScore = _displayScoreTarget.toDouble();
  }

  void _startScoreCountAnimation(int target) {
    _displayScoreStart = _displayScore;
    _displayScoreTarget = target;
    _displayScoreAnimElapsed = 0;

    final delta = (target - _displayScoreStart).abs();
    final normalized = (delta / 180).clamp(0.0, 1.0);
    _displayScoreAnimDuration = 0.8 - (0.65 * normalized);
  }
}
