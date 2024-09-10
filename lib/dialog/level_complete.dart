import 'package:circle_game/component/animated_stars.dart';
import 'package:circle_game/component/buttons/image_button.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';

class LevelCompleteDialog extends StatefulWidget {
  final LevelModel level;
  final int index;
  final int score;
  final int xp;
  final int stars;

  const LevelCompleteDialog({
    required this.level,
    this.index = 1,
    this.score = 0,
    this.xp = 0,
    this.stars = 0,
    super.key,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog> {
  int xp = 0;
  int score = 0;
  int stars = 0;

  @override
  void initState() {
    // after page is loaded
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        xp = widget.xp;
        score = widget.score;
        stars = widget.stars;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'You Win',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            AnimatedStars(stars),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Level ${widget.index + 1}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            AnimatedNumberText(
              xp,
              curve: Curves.easeIn,
              duration: const Duration(seconds: 1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              formatter: (value) {
                return 'XP +$value';
              },
            ),
            const SizedBox(
              height: 10,
            ),
            AnimatedNumberText(
              score,
              curve: Curves.easeIn,
              duration: const Duration(seconds: 1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              formatter: (value) {
                return 'Points +$value';
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageButton(
                  imagePath: 'assets/buttons/dialog_home.png',
                  size: ImageButtonSize.medium,
                  onPressed: () {
                    Navigator.of(context).pop("HOME");
                  },
                ),
                ImageButton(
                  imagePath: 'assets/buttons/dialog_replay.png',
                  size: ImageButtonSize.medium,
                  onPressed: () {
                    Navigator.of(context).pop("REPLAY");
                  },
                ),
                ImageButton(
                  imagePath: 'assets/buttons/dialog_next.png',
                  size: ImageButtonSize.medium,
                  onPressed: () {
                    Navigator.of(context).pop("NEXT");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
