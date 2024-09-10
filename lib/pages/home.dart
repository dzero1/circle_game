import 'package:circle_game/component/buttons/image_button.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:circle_game/pages/levels.dart';
import 'package:circle_game/theme/base_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void loadBackgroundMusic() async {
    // if (!kDebugMode) {
    audioController.startMusic('assets/audio/intro-loop.mp3', looping: true);
    // }
  }

  @override
  void initState() {
    loadBackgroundMusic();
    // maxGlobalVolume = musicManager.getGlobalVolume();

    super.initState();
  }

  @override
  void dispose() async {
    /* if (homeBackgroundMusic != null) {
      await musicManager.stop(homeBackgroundMusic!.handle);
      await musicManager.disposeSource(homeBackgroundMusic!.audioSource);
    } */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseTheme(
      child: SizedBox(
        height: 400,
        child: Column(children: [
          // Title
          Image.asset(
            'assets/game-title.png',
            width: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.contain,
          ),

          // Start button
          ImageButton(
            imagePath: 'assets/buttons/start_button.png',
            onPressed: () {
              Navigator.of(context).pushNamed(LevelsPage.routeName);
            },
          ),

          if (kDebugMode)
            ElevatedButton(
              onPressed: () async {
                await levelManager.reset();
                await playerManager.reset();
              },
              child: const Text("Reset"),
            )
        ]),
      ),
    );
  }
}
