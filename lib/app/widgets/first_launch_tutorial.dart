import 'package:flutter/material.dart';

import '../../game/localization/game_localization.dart';

class FirstLaunchTutorial extends StatelessWidget {
  const FirstLaunchTutorial({
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.onStart,
    super.key,
  });

  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textDirection = GameLocalization.isRtl(selectedLanguage)
        ? TextDirection.rtl
        : TextDirection.ltr;
    final title = switch (selectedLanguage) {
      GameLocalization.korean => '튜토리얼',
      GameLocalization.chinese => '新手教程',
      GameLocalization.japanese => 'チュートリアル',
      GameLocalization.french => 'Tutoriel',
      GameLocalization.arabic => 'الشرح',
      GameLocalization.russian => 'Обучение',
      _ => 'Tutorial',
    };
    final guide1 = switch (selectedLanguage) {
      GameLocalization.korean => '아래 블록 3개 중 1개를 선택해서 보드에 놓으세요.',
      GameLocalization.chinese => '从底部 3 个方块中选择 1 个放到棋盘上。',
      GameLocalization.japanese => '下の3つのブロックから1つ選んで盤面に置きます。',
      GameLocalization.french =>
        'Choisissez 1 bloc sur 3 puis placez-le sur le plateau.',
      GameLocalization.arabic => 'اختر قالبًا واحدًا من ثلاثة وضعه على اللوح.',
      GameLocalization.russian => 'Выберите 1 из 3 блоков и поставьте на поле.',
      _ => 'Choose 1 of 3 blocks and place it on the board.',
    };
    final guide2 = switch (selectedLanguage) {
      GameLocalization.korean => '줄이 꽉 차면 제거되고 점수를 얻습니다.',
      GameLocalization.chinese => '行或列填满时会被清除并获得分数。',
      GameLocalization.japanese => '列や行が埋まると消えてスコアを獲得します。',
      GameLocalization.french =>
        'Les lignes complètes sont effacées et donnent des points.',
      GameLocalization.arabic => 'عند اكتمال صف أو عمود يتم حذفه وتكسب نقاطًا.',
      GameLocalization.russian =>
        'Заполненные линии очищаются и приносят очки.',
      _ => 'Filled lines are cleared and grant points.',
    };
    final guide3 = switch (selectedLanguage) {
      GameLocalization.korean => '선/악 블록은 특별 효과가 있으니 상황에 맞게 고르세요.',
      GameLocalization.chinese => '天使/恶魔方块有特殊效果，请按局势选择。',
      GameLocalization.japanese => '天使/悪魔ブロックは特殊効果があります。',
      GameLocalization.french =>
        'Les blocs ange/démon ont des effets spéciaux.',
      GameLocalization.arabic => 'قوالب الملاك/الشيطان لها تأثيرات خاصة.',
      GameLocalization.russian => 'Блоки ангела/дьявола имеют особые эффекты.',
      _ => 'Angel/Devil blocks have special effects.',
    };
    final startLabel = switch (selectedLanguage) {
      GameLocalization.korean => '게임 시작',
      GameLocalization.chinese => '开始游戏',
      GameLocalization.japanese => 'ゲーム開始',
      GameLocalization.french => 'Commencer',
      GameLocalization.arabic => 'ابدأ اللعبة',
      GameLocalization.russian => 'Начать игру',
      _ => 'Start Game',
    };

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: Center(
          child: Directionality(
            textDirection: textDirection,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _bullet(guide1),
                    _bullet(guide2),
                    _bullet(guide3),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedLanguage,
                      decoration: InputDecoration(
                        labelText: GameLocalization.languageLabel(
                          selectedLanguage,
                        ),
                        labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF475569),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF60A5FA),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      dropdownColor: const Color(0xFF111827),
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontWeight: FontWeight.w700,
                      ),
                      items: GameLocalization.supportedLanguages
                          .map(
                            (lang) => DropdownMenuItem<String>(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        onLanguageChanged(value);
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onStart,
                        child: Text(
                          startLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}
