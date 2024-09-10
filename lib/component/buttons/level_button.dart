import 'package:circle_game/component/animated_stars.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:circle_game/pages/game.dart';
import 'package:flutter/material.dart';
import 'package:outlined_text/outlined_text.dart';

class LevelButton extends StatefulWidget {
  const LevelButton({super.key, required this.level, this.disabled = true});

  final int level;
  final bool disabled;

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.disabled) {
          await audioController.playSound('assets/audio/click.mp3');
          Navigator.of(context).pushNamed(
            GamePage.routeName,
            arguments: GamePageArguments(widget.level),
          );
        }
      },
      child: Container(
        width: 170,
        height: 170,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: const AssetImage('assets/buttons/level_box.png'),
            fit: BoxFit.cover,
            alignment:
                widget.disabled ? Alignment.centerRight : Alignment.centerLeft,
          ),
        ),
        child: Column(
          children: [
            // Stars area
            SizedBox(
              height: 36,
              child: AnimatedStars(
                levelManager.getStars(widget.level),
                size: StarsSize.small,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // level number
            OutlinedText(
              text: Text(
                (widget.level + 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.disabled ? Colors.grey : Colors.yellow,
                  shadows: [
                    Shadow(
                      offset: const Offset(3.0, 3.0),
                      blurRadius: 1.0,
                      color: widget.disabled
                          ? Colors.grey
                          : const Color.fromARGB(221, 255, 119, 0),
                    ),
                    Shadow(
                      offset: const Offset(3.0, 3.0),
                      blurRadius: 2.0,
                      color: widget.disabled ? Colors.grey : Colors.black87,
                    ),
                  ],
                ),
              ),
              strokes: [
                OutlinedTextStroke(
                  color: widget.disabled
                      ? Colors.black45
                      : const Color.fromARGB(255, 96, 41, 14),
                  width: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
