import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

LevelManager levelManager = LevelManager();

class LevelModel {
  int rings = 0;
  List<int> difficulty = [0];
  List<int> gems = [];
  int xp = 0;
  List<dynamic>? freez;
  List<dynamic>? rock;

  LevelModel({
    required this.rings,
    this.difficulty = const [0],
    this.xp = 0,
    this.gems = const [1],
    this.freez,
    this.rock,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      rings: json['rings'],
      difficulty: json['difficulty'].runtimeType == int
          ? [json['difficulty'] as int]
          : (json['difficulty'] as List<dynamic>).map((e) => e as int).toList(),
      xp: json['xp'],
      gems: json['gems'] == null
          ? [1, 2, 3, 4, 5, 6]
          : (json['gems'] as List<dynamic>).map((e) => e as int).toList(),
      freez: json['freez'],
      rock: json['rock'],
    );
  }
}

class LevelManager {
  final List<LevelModel> _levels = [];
  late final Box levelBox;

  String _user_accessible_level = 'user_accessible_level';

  init() async {
    levelBox = await Hive.openBox('level_manager');

    // read fom assets/levels.json
    List jsonLevels = [];
    if (!kDebugMode) {
      final String response =
          await rootBundle.loadString('${!kIsWeb ? "assets/" : ""}levels.json');
      jsonLevels = await json.decode(response);
      print(jsonLevels);
    } else {
      jsonLevels = [
        {
          "rings": 5,
          "difficulty": [0, 4],
          "gems": [1, 2],
          "freez": [
            1,
            [1, 2, 4, 5]
          ],
          "rock": [
            [2, 4],
            [3, 6, 7]
          ],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        },
        {
          "rings": 1,
          "difficulty": [0],
          "gems": [1, 2, 3],
          "xp": 1000
        }
      ];
    }

    for (var level in jsonLevels) {
      _levels.add(LevelModel.fromJson(level));
    }

    // print(_levels);
  }

  getLevelCount() {
    return _levels.length;
  }

  getLevel(int level) {
    return _levels[level];
  }

  Future<int> getUserAccessibleLevel() async {
    return levelBox.get(_user_accessible_level, defaultValue: 0) as int;
  }

  updateUserAccessibleLevel(int nextLevel) async {
    int lastKnownAccessibleLevel =
        levelBox.get(_user_accessible_level, defaultValue: 0);
    return levelBox.put(
        _user_accessible_level, max(lastKnownAccessibleLevel, nextLevel));
  }

  unlockNextLevel(currentLevel) async {
    String key = 'level_${currentLevel + 1}';

    // set next level active
    levelBox.put(key, true);

    // update the max accessible level
    await updateUserAccessibleLevel(currentLevel + 1);

    // return max accessible level
    return levelBox.put(key, await getUserAccessibleLevel() + 1);
  }

  calculateScore(index) async {
    num score =
        index < await getUserAccessibleLevel() ? 100 : 100 + (50 * (index + 1));
    return score.toInt();
  }

  calculateXP(index) async {
    num score =
        index < await getUserAccessibleLevel() ? 10 : 1110 - (10 * (index + 1));
    return score.toInt();
  }

  int saveStars(int index, int stars) {
    levelBox.put('level_${index}_stars', max(getStars(index), stars));
    return getStars(index);
  }

  int getStars(int index) {
    return levelBox.get('level_${index}_stars', defaultValue: 0);
  }

  reset() async {
    await levelBox.delete(_user_accessible_level);
    for (var i = 0; i < _levels.length; i++) {
      await levelBox.delete('level_${i}_stars');
    }
  }
}
