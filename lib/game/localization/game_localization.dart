class GameLocalization {
  static const String english = 'English';
  static const String korean = '한국어';
  static const String chinese = '中文';
  static const String japanese = '日本語';
  static const String french = 'Français';
  static const String arabic = 'العربية';
  static const String russian = 'Русский';

  static const List<String> supportedLanguages = <String>[
    english,
    korean,
    chinese,
    japanese,
    french,
    arabic,
    russian,
  ];

  static bool isRtl(String language) => language == arabic;

  static String settingsTitle(String language) => switch (language) {
    korean => '설정',
    chinese => '设置',
    japanese => '設定',
    french => 'Paramètres',
    arabic => 'الإعدادات',
    russian => 'Настройки',
    _ => 'Setting',
  };

  static String restart(String language) => switch (language) {
    korean => '재시작',
    chinese => '重新开始',
    japanese => '再開',
    french => 'Redémarrer',
    arabic => 'إعادة التشغيل',
    russian => 'Перезапуск',
    _ => 'Restart',
  };

  static String exit(String language) => switch (language) {
    korean => '종료',
    chinese => '退出',
    japanese => '終了',
    french => 'Quitter',
    arabic => 'خروج',
    russian => 'Выход',
    _ => 'Exit',
  };

  static String basicTheme(String language) => switch (language) {
    korean => '기본',
    chinese => '基础',
    japanese => '基本',
    french => 'Base',
    arabic => 'أساسي',
    russian => 'Базовый',
    _ => 'Basic',
  };

  static String customTheme(String language) => switch (language) {
    korean => '커스텀',
    chinese => '自定义',
    japanese => 'カスタム',
    french => 'Personnalisé',
    arabic => 'مخصص',
    russian => 'Пользовательский',
    _ => 'Custom',
  };

  static String colorfulTheme(String language) => switch (language) {
    korean => '컬러풀',
    chinese => '多彩',
    japanese => 'カラフル',
    french => 'Coloré',
    arabic => 'ملون',
    russian => 'Цветной',
    _ => 'Colorful',
  };

  static String customColor(String language) => switch (language) {
    korean => '커스텀 색상',
    chinese => '自定义颜色',
    japanese => 'カスタムカラー',
    french => 'Couleur personnalisée',
    arabic => 'لون مخصص',
    russian => 'Пользовательский цвет',
    _ => 'Custom Color',
  };

  static String languageLabel(String language) => switch (language) {
    korean => '언어',
    chinese => '语言',
    japanese => '言語',
    french => 'Langue',
    arabic => 'اللغة',
    russian => 'Язык',
    _ => 'Language',
  };

  static String topScoreLabel(String language, int bestScore) =>
      switch (language) {
        korean => '최고 $bestScore',
        chinese => '最高 $bestScore',
        japanese => '最高 $bestScore',
        french => 'MEILLEUR $bestScore',
        arabic => 'الأفضل $bestScore',
        russian => 'РЕКОРД $bestScore',
        _ => 'TOP $bestScore',
      };

  static String currentScoreLabel(String language) => switch (language) {
    korean => '현재 점수',
    chinese => '当前分数',
    japanese => '現在スコア',
    french => 'SCORE ACTUEL',
    arabic => 'النقاط الحالية',
    russian => 'ТЕКУЩИЙ СЧЕТ',
    _ => 'CURRENT SCORE',
  };

  static String turnStoredLabel(String language, int turn, int storedScore) =>
      switch (language) {
        korean => '턴 $turn   |   저장 $storedScore',
        chinese => '回合 $turn   |   储存 $storedScore',
        japanese => 'ターン $turn   |   保存 $storedScore',
        french => 'TOUR $turn   |   STOCKÉ $storedScore',
        arabic => 'الدور $turn   |   المخزن $storedScore',
        russian => 'ХОД $turn   |   НАКОПЛЕНО $storedScore',
        _ => 'TURN $turn   |   STORED $storedScore',
      };

  static String comboLabel(String language, int comboCount) =>
      switch (language) {
        korean => '콤보 x$comboCount',
        chinese => '连击 x$comboCount',
        japanese => 'コンボ x$comboCount',
        french => 'COMBO x$comboCount',
        arabic => 'كومبو x$comboCount',
        russian => 'КОМБО x$comboCount',
        _ => 'COMBO x$comboCount',
      };

  static String fateTypeLabel(String language, bool isAngel) {
    if (isAngel) {
      return switch (language) {
        korean => '천사',
        chinese => '天使',
        japanese => '天使',
        french => 'ANGE',
        arabic => 'ملاك',
        russian => 'АНГЕЛ',
        _ => 'ANGEL',
      };
    }
    return switch (language) {
      korean => '악마',
      chinese => '恶魔',
      japanese => '悪魔',
      french => 'DIABLE',
      arabic => 'شيطان',
      russian => 'ДЬЯВОЛ',
      _ => 'DEVIL',
    };
  }

  static String gameOverTitle(String language) => switch (language) {
    korean => '게임 오버',
    chinese => '游戏结束',
    japanese => 'ゲームオーバー',
    french => 'PARTIE TERMINÉE',
    arabic => 'انتهت اللعبة',
    russian => 'ИГРА ОКОНЧЕНА',
    _ => 'GAME OVER',
  };

  static String gameOverHint(String language) => switch (language) {
    korean => '아무 곳이나 탭하면 다시 시작',
    chinese => '点击任意处重新开始',
    japanese => 'どこでもタップして再開',
    french => 'Touchez pour redémarrer',
    arabic => 'المس أي مكان لإعادة البدء',
    russian => 'Нажмите в любом месте для перезапуска',
    _ => 'Tap anywhere to restart',
  };

  static String angelEffectComboShield(String language) => switch (language) {
    korean => '콤보 실드 준비 (1턴)',
    chinese => '连击护盾已准备（1回合）',
    japanese => 'コンボシールド準備 (1ターン)',
    french => 'Bouclier combo prêt (1 tour)',
    arabic => 'درع الكومبو جاهز (دور واحد)',
    russian => 'Щит комбо готов (1 ход)',
    _ => 'Combo shield ready (1 turn)',
  };

  static String angelEffectCleanup(String language, int removed) =>
      switch (language) {
        korean => '가장 많은 줄 정리: $removed칸',
        chinese => '最多一线清理：$removed格',
        japanese => '最多ライン整理: $removedマス',
        french => 'Nettoyage de ligne: $removed cases',
        arabic => 'تنظيف أكثر خط امتلاء: $removed خلية',
        russian => 'Очистка заполненной линии: $removed клеток',
        _ => 'Most-filled line cleanup: $removed cell(s)',
      };

  static String angelBanner(
    String language,
    int payout,
    String effectSummary,
  ) => switch (language) {
    korean => '저장 +$payout, $effectSummary',
    chinese => '储存 +$payout，$effectSummary',
    japanese => '保存 +$payout, $effectSummary',
    french => 'Stocké +$payout, $effectSummary',
    arabic => 'المخزن +$payout، $effectSummary',
    russian => 'Накоплено +$payout, $effectSummary',
    _ => 'Stored +$payout, $effectSummary',
  };

  static String devilPenaltyBanner(String language) => switch (language) {
    korean => '악마 패널티: 점수 -10%',
    chinese => '恶魔惩罚：分数 -10%',
    japanese => '悪魔ペナルティ: スコア -10%',
    french => 'Pénalité démon: -10% score',
    arabic => 'عقوبة الشيطان: -10% نقاط',
    russian => 'Штраф дьявола: -10% очков',
    _ => 'Devil penalty: -10% score',
  };
}
