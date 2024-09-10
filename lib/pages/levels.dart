import 'package:circle_game/component/buttons/level_button.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:circle_game/theme/base_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outlined_text/outlined_text.dart';

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});
  static const String routeName = '/levels';

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  int maxAccessibleLevel = 0;

  @override
  void initState() {
    init();

    emitter.on("GAME_EXIT", this, (ev, context) async {
      await init();
      if (mounted) setState(() {});
    });

    super.initState();
  }

  init() async {
    maxAccessibleLevel = await levelManager.getUserAccessibleLevel();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseTheme(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: OutlinedText(
              text: Text(
                "Select Level",
                style: GoogleFonts.nerkoOne().copyWith(
                  fontSize: 40,
                  color: Colors.amber,
                  shadows: const [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              strokes: [
                OutlinedTextStroke(
                  color: const Color.fromARGB(255, 95, 38, 0),
                  width: 8,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 320,
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // childAspectRatio: 1,
              ),
              primary: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return LevelButton(
                  disabled: index > maxAccessibleLevel,
                  level: index,
                );
              },
              itemCount: levelManager.getLevelCount(),
            ),
          ),
        ],
      ),
    );
  }
}
