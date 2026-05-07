import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../game/dual_blocks_game.dart';
import '../game/localization/game_localization.dart';
import 'widgets/first_launch_tutorial.dart';
import 'widgets/settings_modal.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DualBlocksGame _game;
  bool _isInitializing = true;
  bool _showTutorial = false;
  String _tutorialLanguage = GameLocalization.english;

  @override
  void initState() {
    super.initState();
    _game = DualBlocksGame();
    _initializeAppState();
  }

  @override
  void dispose() {
    _game.closeSettingsModal();
    super.dispose();
  }

  Future<void> _initializeAppState() async {
    final prefsState = await AppPrefs.load();
    _game.applyPersistedState(prefsState);
    if (!mounted) return;
    setState(() {
      _tutorialLanguage = prefsState.language;
      _showTutorial = !prefsState.tutorialCompleted;
      _isInitializing = false;
    });
  }

  Future<void> _completeTutorial() async {
    _game.setLanguage(_tutorialLanguage);
    await AppPrefs.setTutorialCompleted(true);
    if (!mounted) return;
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF020617),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ValueListenableBuilder<bool>(
        valueListenable: _game.settingsModalVisible,
        builder: (context, isVisible, _) {
          return PopScope(
            canPop: !isVisible && !_showTutorial,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && isVisible) {
                _game.closeSettingsModal();
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF020617),
              body: Stack(
                children: [
                  SafeArea(child: GameWidget(game: _game)),
                  if (isVisible)
                    SettingsModal(
                      game: _game,
                      onClose: _game.closeSettingsModal,
                    ),
                  if (_showTutorial)
                    FirstLaunchTutorial(
                      selectedLanguage: _tutorialLanguage,
                      onLanguageChanged: (value) {
                        setState(() => _tutorialLanguage = value);
                      },
                      onStart: _completeTutorial,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
