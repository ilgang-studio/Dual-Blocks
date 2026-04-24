import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/dual_blocks_game.dart';
import 'widgets/settings_modal.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DualBlocksGame _game;

  @override
  void initState() {
    super.initState();
    _game = DualBlocksGame();
  }

  @override
  void dispose() {
    _game.closeSettingsModal();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            GameWidget(game: _game),
            ValueListenableBuilder<bool>(
              valueListenable: _game.settingsModalVisible,
              builder: (context, isVisible, _) {
                if (!isVisible) return const SizedBox.shrink();
                return SettingsModal(
                  game: _game,
                  onClose: _game.closeSettingsModal,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
