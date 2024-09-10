import 'package:circle_game/helpers/levels_manager.dart';
import 'package:circle_game/helpers/player_manager.dart';
import 'package:circle_game/helpers/sound_manager.dart';
import 'package:circle_game/pages/game.dart';
import 'package:circle_game/pages/home.dart';
import 'package:circle_game/pages/levels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App full-screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Init Hive
  await Hive.initFlutter();

  // Audio Manager
  await audioController.initialize();

  // Level Manager
  await levelManager.init();

  // Player Manager
  await playerManager.init();

  // preload click fx to smooth sound
  // await preloadFXSource('assets/audio/click.mp3');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle of Life',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        textTheme: GoogleFonts.mPlusRounded1cTextTheme(),
      ),
      home: const MyHomePage(),
      routes: {
        GamePage.routeName: (context) => const GamePage(),
        LevelsPage.routeName: (context) => const LevelsPage(),
      },
    );
  }
}
