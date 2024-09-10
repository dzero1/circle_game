import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexagon/hexagon.dart';

class ScoreProgress extends StatefulWidget {
  const ScoreProgress({super.key});

  @override
  State<ScoreProgress> createState() => _ScoreProgressState();
}

class _ScoreProgressState extends State<ScoreProgress> {
  int score = 0;
  int level = 0;
  LevelCaps? lc;

  @override
  void initState() {
    score = playerManager.getScore();
    level = playerManager.getLevel();
    lc = playerManager.getLevelCap();
    emitter.on(
      "SCORE_UPDATE",
      this,
      (ev, context) {
        if (mounted) {
          setState(() {
            score = playerManager.getScore();
          });
        }
      },
    );
    emitter.on(
      PlayerManager.EVENT_LEVEL_UPDATE,
      this,
      (ev, context) {
        if (mounted) {
          setState(() {
            level = playerManager.getLevel();
          });
        }
      },
    );
    super.initState();
  }

  double calcProgress() {
    lc = playerManager.getLevelCap();
    return score / lc!.max;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 45,
      child: Stack(
        children: [
          Positioned(
            left: 28,
            top: 8,
            child: Container(
              width: 80,
              height: 20,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(
                      begin: 0,
                      end: calcProgress(),
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 20,
                      color: Colors.lightBlueAccent,
                      backgroundColor: Colors.black87,
                    ),
                  ),
                  SizedBox.expand(
                    child: AnimatedNumberText(
                      score,
                      curve: Curves.easeIn,
                      duration: const Duration(seconds: 1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nerkoOne().copyWith(
                        color: Colors.white,
                      ),
                      formatter: (value) => "$value / ${lc!.max}",
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: HexagonWidget(
              type: HexagonType.POINTY,
              width: 36,
              height: 36,
              elevation: 3,
              color: Colors.lightBlueAccent,
              child: AnimatedDigitWidget(
                value: level,
                textStyle: GoogleFonts.nerkoOne()
                    .copyWith(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
