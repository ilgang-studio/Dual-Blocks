import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/dual_blocks_game.dart';
import '../../game/localization/game_localization.dart';
import '../../game/models/ui/block_theme_mode.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({required this.game, required this.onClose, super.key});

  final DualBlocksGame game;
  final VoidCallback onClose;

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late BlockThemeMode _themeMode;
  late Color _customColor;
  late String _language;

  static const _languages = GameLocalization.supportedLanguages;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.game.selectedThemeMode;
    _customColor = widget.game.selectedCustomThemeColor;
    _language = widget.game.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width < 420 ? size.width * 0.92 : 400.0;
    final panelPadding = size.width < 360 ? 16.0 : 20.0;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onClose,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: EdgeInsets.all(panelPadding),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        GameLocalization.settingsTitle(_language),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildThemeSelector(),
                      const SizedBox(height: 16),
                      _buildCustomColorSection(),
                      const SizedBox(height: 20),
                      _buildLanguageSection(),
                      const SizedBox(height: 22),
                      _buildActionButton(
                        label: GameLocalization.restart(_language),
                        onPressed: widget.game.restartFromSettings,
                      ),
                      const SizedBox(height: 10),
                      _buildActionButton(
                        label: GameLocalization.exit(_language),
                        onPressed: () async {
                          widget.onClose();
                          await SystemNavigator.pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final items = <({BlockThemeMode mode, String label})>[
      (
        mode: BlockThemeMode.solid,
        label: GameLocalization.basicTheme(_language),
      ),
      (
        mode: BlockThemeMode.custom,
        label: GameLocalization.customTheme(_language),
      ),
      (
        mode: BlockThemeMode.rainbow,
        label: GameLocalization.colorfulTheme(_language),
      ),
    ];

    return Row(
      children: items.map((item) {
        final selected = _themeMode == item.mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF111827),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF475569),
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() => _themeMode = item.mode);
                widget.game.setThemeMode(item.mode);
              },
              child: Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomColorSection() {
    final hue = HSLColor.fromColor(_customColor).hue;
    final enabled = _themeMode == BlockThemeMode.custom;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              GameLocalization.customColor(_language),
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth - 72;
                final thumbX = (hue / 360) * barWidth;

                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanDown: (details) {
                          _updateHue(details.localPosition.dx, barWidth);
                        },
                        onPanUpdate: (details) {
                          _updateHue(details.localPosition.dx, barWidth);
                        },
                        onTapDown: (details) {
                          _updateHue(details.localPosition.dx, barWidth);
                        },
                        child: SizedBox(
                          height: 26,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF475569),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFF97316),
                                      Color(0xFFFACC15),
                                      Color(0xFF22C55E),
                                      Color(0xFF06B6D4),
                                      Color(0xFF3B82F6),
                                      Color(0xFFA855F7),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: thumbX.clamp(0, barWidth - 2),
                                top: -1,
                                child: Container(
                                  width: 3,
                                  height: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _customColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              _toHex(_customColor),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            GameLocalization.languageLabel(_language),
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF475569)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _language,
              dropdownColor: const Color(0xFF111827),
              iconEnabledColor: const Color(0xFFE2E8F0),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              items: _languages
                  .map(
                    (lang) => DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _language = value);
                widget.game.setLanguage(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF0B1220),
          side: const BorderSide(color: Color(0xFF475569)),
          foregroundColor: const Color(0xFFE2E8F0),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _updateHue(double x, double width) {
    final clampedX = x.clamp(0, width);
    final hue = (clampedX / width) * 360;
    final color = HSLColor.fromAHSL(1, hue, 0.9, 0.55).toColor();
    setState(() => _customColor = color);
    widget.game.setCustomThemeColor(color);
  }

  String _toHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
