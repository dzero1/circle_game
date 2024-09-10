import 'dart:async';
import 'dart:math';

import 'package:circle_game/component/circle_placeholder.dart';
import 'package:circle_game/component/drag_target.dart';
import 'package:circle_game/dialog/level_complete.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:circle_game/theme/base_theme.dart';
import 'package:flutter/material.dart';

class GamePageArguments {
  final int level;
  GamePageArguments(this.level);
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  static const String routeName = '/game';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late LevelModel currentLevel;
  List placeholders = [];
  List completedSet = [];
  int level = 0;
  bool _visible = false;
  double gemSize = 25;

  bool isLoading = true;

  /* Star rating */
  List<double> eachRingStarTimeComplexity = [];
  List<double> eachRingMistakeComplexity = [];
  double starTimeComplexity = 0;
  double starMistakesComplexity = 0;
  double starMistakes = 0;

  int playStart = 0;

  late GamePageArguments args;

  initSounds() async {
    // if (kDebugMode) return;

    // Stop home page music
    /* if (homeBackgroundMusic != null) {
      await musicManager.stop(homeBackgroundMusic!.handle);
      await musicManager.disposeSource(homeBackgroundMusic!.audioSource);
    } */

    audioController.startMusic('assets/audio/game-music-loop.mp3',
        looping: true);
  }

  initLevel() async {
    setState(() {
      isLoading = true;
    });

    starTimeComplexity = 0;
    starMistakesComplexity = 0;
    starMistakes = 0;
    eachRingStarTimeComplexity = [];
    eachRingMistakeComplexity = [];

    currentLevel = await levelManager.getLevel(level);
    completedSet = List.generate(currentLevel.rings, (_) => false);
    placeholders = List.generate(
      currentLevel.rings,
      (index) {
        double difficulty = 0;

        if (currentLevel.difficulty.length > index) {
          difficulty = currentLevel.difficulty[index].toDouble();
        } else {
          /**
          * difficulty = [0,1,2]
          * index = 5
          * i = 5 - difficulty.length
          * x = difficulty % index
          */
          /* int i = index;
          while (i >= currentLevel.difficulty.length) {
            i -= currentLevel.difficulty.length;
          }
          difficulty = currentLevel.difficulty[i].toDouble(); */
          difficulty = currentLevel.difficulty[0].toDouble();
        }

        /**
         * How star time complexity calculate
         * (rings + 4 = because minimum rings should be 4) x (max difficulty) 
         *    x (1.5 = average time complexity of each placeholder) 
         *    x gems count
         *    x to milliseconds
         * */

        double timePerPlaceholder = 2.0;

        double fx = 0;
        double mx = 0;

        int i = index;
        bool isFrozen = false;

        for (var j = 0; j < (difficulty + 4); j++) {
          if (currentLevel.freez != null && currentLevel.freez!.length > i) {
            if (currentLevel.freez![i].runtimeType == int) {
              isFrozen = currentLevel.freez![i] as int == 1;
            } else {
              isFrozen = currentLevel.freez![i].contains(j + 1);
            }
          }
          if (isFrozen) fx += timePerPlaceholder;

          bool isRocked = false;
          if (currentLevel.rock != null && currentLevel.rock!.length > i) {
            if (currentLevel.rock![i].runtimeType == int) {
              isRocked = currentLevel.rock![i] as int == 1;
            } else {
              isRocked = currentLevel.rock![i].contains(j + 1);
            }
          }
          if (isRocked) fx += timePerPlaceholder;

          // if both true 1 increase, else one of them true increase by 1
          mx += isFrozen && isRocked ? 1 : (isFrozen || isRocked ? 1 : 0);
        }

        double dx = difficulty + 4;
        double ringComplex =
            (dx * (max(1.0, difficulty) * 0.66) * timePerPlaceholder * 1000) +
                (currentLevel.gems.length *
                    (currentLevel.gems.length * 0.66) *
                    1000) +
                (fx * 1000);
        eachRingStarTimeComplexity.add(ringComplex);

        double mistakeComplex =
            max(1.0, difficulty) + max(1.0, (mx / max(1.0, difficulty)));
        eachRingMistakeComplexity.add(mistakeComplex.floor().toDouble());

        return CirclePlaceholder(
          level: currentLevel,
          ringIndex: index,
          difficulty: difficulty.toInt(),
          gemSize: gemSize,
          onMistake: () {
            starMistakes++;
          },
          onCompleted: () {
            debugPrint('Completed $index');
            completedSet[index] = true;

            // load next level
            _visible = false;
            finishLevel();
          },
        );
      },
    ).reversed.toList();

    /**
     * Stars 
     * 
     * */
    starTimeComplexity = eachRingStarTimeComplexity.reduce(
      (value, element) => value + element,
    );
    starMistakesComplexity = eachRingMistakeComplexity.reduce(
      (value, element) => value + element,
    );

    debugPrint(
        "starTimeComplexity: $starTimeComplexity, starMistakesComplexity: $starMistakesComplexity");

    _visible = true;

    // start timer - wait for visible animation
    Future.delayed(const Duration(milliseconds: 600), () {
      playStart = DateTime.now().millisecondsSinceEpoch;
    });

    setState(() {
      isLoading = false;
    });
  }

  finishLevel() {
    if (completedSet.where((e) => e == false).isEmpty) {
      // TODO: Should run level complete animation

      Future.delayed(const Duration(seconds: 1), () async {
        debugPrint("Level Completed!");

        int stars = 1;
        int playEnd = DateTime.now().millisecondsSinceEpoch - playStart;

        debugPrint("playEnd: $playEnd, starMistakes: $starMistakes");

        if (playEnd < starTimeComplexity) {
          stars++;
        }
        if (starMistakes <= 2) {
          stars++;
        }
        await levelManager.saveStars(level, stars);

        // Show level complete dialog
        final xp = await levelManager.calculateXP(level);
        await playerManager.addXP(xp);

        final score = await levelManager.calculateScore(level);
        await playerManager.addScore(score);

        await levelManager.unlockNextLevel(level);

        final mode = await showLevelComplete(score, xp, stars);

        setState(() {
          completedSet = [];
          placeholders = [];
        });

        switch (mode) {
          case "HOME":
            Navigator.of(context).pop();
            break;
          case "REPLAY":
            await Future.delayed(const Duration(seconds: 1));
            initLevel();
            break;
          case "NEXT":
            await Future.delayed(const Duration(seconds: 1));
            level++;
            initLevel();
            break;
          default:
        }
      });
    }
  }

  Future showLevelComplete(int score, int xp, int stars) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => LevelCompleteDialog(
        level: currentLevel,
        index: level,
        score: score,
        xp: xp,
        stars: stars,
      ),
    );
  }

  @override
  void initState() {
    // after page is loaded
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        args = ModalRoute.of(context)!.settings.arguments as GamePageArguments;
        print(args);
        level = args.level;
      } catch (e) {
        print(e);
      }
      initLevel();
      initSounds();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double maxSize = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        audioController.startMusic('assets/audio/intro-loop.mp3',
            looping: true);
        emitter.emit("GAME_EXIT");
      },
      child: BaseTheme(
        backgroundImage: 'assets/background/game-background.jpg',
        inGame: true,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Container(
                    width: maxSize,
                    height: maxSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background/rock-round.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (!isLoading) ...placeholders,
                          Center(
                            child: DragTargetWidget(
                              gemSet: currentLevel.gems,
                              size: gemSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
