import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

List<Color> colors = [
  Colors.redAccent,
  Colors.lightBlueAccent,
  Colors.lightGreenAccent,
  Colors.yellowAccent,
  Colors.deepPurpleAccent,
  Colors.orangeAccent
];

List gems = [
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_red.png'),
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_blue.png'),
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_green.png'),
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_yellow.png'),
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_purple.png'),
  Image.asset('${!kIsWeb ? 'assets/' : ''}gems/gem_orange.png'),
];
