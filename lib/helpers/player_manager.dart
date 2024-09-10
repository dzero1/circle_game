// ignore_for_file: constant_identifier_names

import 'package:circle_game/helpers/levels_manager.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:eventify/eventify.dart';

EventEmitter emitter = EventEmitter();

PlayerManager playerManager = PlayerManager();

class PlayerManager {
  static const String EVENT_COINS_UPDATE = 'COINS_UPDATE';

  static const String EVENT_SCORE_UPDATE = 'SCORE_UPDATE';
  static const String EVENT_LEVEL_UPDATE = 'LEVEL_UPDATE';

  static const String EVENT_XP_UPDATE = 'XP_UPDATE';
  static const String EVENT_XP_LEVEL_UPDATE = 'XP_LEVEL_UPDATE';

  late Guid playerId;
  late Box playerBox;

  late Map<int, int> levelCaps;
  late Map<int, int> xpCaps;

  Future<void> init() async {
    playerBox = await Hive.openBox('player_manager');
    playerId = Guid(
      playerBox.get(
        'playerId',
        defaultValue: Guid.newGuid.toString(),
      ),
    );
    // levelCaps = List.generate(100).reduce((value, element) => value + element * 1000,);

    int lastLevelCap = 0;
    int lastXPCap = 0;

    levelCaps = Map.fromIterable(List.generate(100, (index) => index + 1),
        value: (value) {
      lastLevelCap += value * 200 as int;
      return lastLevelCap;
    });
    xpCaps = Map.fromIterable(List.generate(100, (index) => index + 1),
        value: (value) {
      lastXPCap += value * 1000 as int;
      return lastXPCap;
    });
  }

  /* XP */
  getXP() {
    return playerBox.get('xp', defaultValue: 0);
  }

  addXP(int newXP) async {
    playerBox.put('xp', getXP() + newXP);
    await setXPLevel();
    emitter.emit(EVENT_XP_UPDATE);
    return getXP();
  }

  getXPLevel() {
    return playerBox.get('XP_level', defaultValue: 0);
  }

  setXPLevel() async {
    int score = getXP();

    // find the caps from score
    for (var key in xpCaps.keys) {
      int value = xpCaps[key]!;
      if (score >= value) {
        playerBox.put('XP_level', key);
        emitter.emit(EVENT_XP_LEVEL_UPDATE);
      }
    }
  }

  getXPLevelCap({int? currentLevel}) {
    int lvl = currentLevel ?? getXPLevel();
    return LevelCaps(min: lvl <= 0 ? 0 : xpCaps[lvl]!, max: xpCaps[lvl + 1]!);
  }

  /* Score & Level */
  getScore() {
    return playerBox.get('score', defaultValue: 0);
  }

  addScore(newScore) async {
    playerBox.put('score', getScore() + newScore);
    await setLevel();
    emitter.emit(EVENT_SCORE_UPDATE);
    return getScore();
  }

  getLevel() {
    return playerBox.get('level', defaultValue: 0);
  }

  setLevel() async {
    int score = getScore();

    // find the caps from score
    for (var key in levelCaps.keys) {
      int value = levelCaps[key]!;
      if (score >= value) {
        playerBox.put('level', key);
        emitter.emit(EVENT_LEVEL_UPDATE);
      }
    }
  }

  getLevelCap({int? currentLevel}) {
    int lvl = currentLevel ?? getLevel();
    return LevelCaps(
        min: lvl <= 0 ? 0 : levelCaps[lvl]!, max: levelCaps[lvl + 1]!);
  }

  /* Coins */
  getCoins() {
    return playerBox.get('coins', defaultValue: 0);
  }

  addCoins({int coins = 1}) {
    playerBox.put('coins', getCoins() + coins);
    emitter.emit(EVENT_COINS_UPDATE);
    return getXP();
  }

  /* Reset */
  reset() async {
    await playerBox.delete('score');
    await playerBox.delete('xp');
    await playerBox.delete('level');
    await playerBox.delete('coins');
    await playerBox.delete('XP_level');
  }
}

class LevelCaps {
  int min = 0;
  int max = 0;
  LevelCaps({required this.min, required this.max});
}
