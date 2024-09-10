import 'package:circle_game/component/buttons/image_button.dart';
import 'package:circle_game/component/score_progress.dart';
import 'package:circle_game/component/xp_progress.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:flutter/material.dart';

class BaseTheme extends StatefulWidget {
  final Widget? child;
  final String? backgroundImage;
  final bool inGame;

  const BaseTheme(
      {super.key, this.child, this.backgroundImage, this.inGame = false});

  @override
  State<BaseTheme> createState() => _BaseThemeState();
}

class _BaseThemeState extends State<BaseTheme> {
  @override
  Widget build(BuildContext context) {
    AppBar tmpAppBar = AppBar();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // render background
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.backgroundImage ??
                      'assets/background/homepage-background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // render menu
          Positioned(
            top: tmpAppBar.preferredSize.height,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.inGame)
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // XP and score
                          XpProgress(),
                          ScoreProgress(),
                        ],
                      ),
                    ),
                  if (!widget.inGame)
                    const SizedBox(
                      width: 10,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ImageButton(
                        imagePath: 'assets/buttons/sound_on_off.png',
                        size: ImageButtonSize.small,
                        stateButton: true,
                        onPressed: () {
                          setState(() {
                            audioController.toggleMuteFX();
                            audioController.toggleMuteMusic();
                          });
                        },
                      ),
                      if (!widget.inGame)
                        ImageButton(
                          imagePath: 'assets/buttons/exit.png',
                          size: ImageButtonSize.small,
                          onPressed: () {},
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // render page
          Positioned(
            top: tmpAppBar.preferredSize.height,
            left: 0,
            child: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    tmpAppBar.preferredSize.height,
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
