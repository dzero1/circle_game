import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:circle_game/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XpProgress extends StatefulWidget {
  const XpProgress({super.key});

  @override
  State<XpProgress> createState() => _XpProgressState();
}

class _XpProgressState extends State<XpProgress> {
  int xp = 0;
  int level = 0;
  LevelCaps? lc;

  @override
  void initState() {
    xp = playerManager.getXP();
    level = playerManager.getXPLevel();
    lc = playerManager.getLevelCap();

    emitter.on(
      "XP_UPDATE",
      this,
      (ev, context) {
        if (mounted) {
          setState(() {
            xp = playerManager.getXP();
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
            level = playerManager.getXPLevel();
          });
        }
      },
    );

    super.initState();
  }

  double calcProgress() {
    lc = playerManager.getXPLevelCap();
    return xp / lc!.max;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 40,
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
                      color: Colors.amber,
                      backgroundColor: Colors.black87,
                    ),
                  ),
                  SizedBox.expand(
                    child: AnimatedNumberText(
                      xp,
                      curve: Curves.easeIn,
                      duration: const Duration(seconds: 1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nerkoOne().copyWith(
                        color: Colors.white,
                      ),
                      formatter: (value) {
                        return '${numberDisplay(value)}/${numberDisplay(lc!.max)}';
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
