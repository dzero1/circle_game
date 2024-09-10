import 'dart:math';

import 'package:circle_game/component/drop_target.dart';
import 'package:circle_game/helpers/game_elements.dart';
import 'package:circle_game/helpers/levels_manager.dart';
import 'package:flutter/material.dart';

class CirclePlaceholder extends StatefulWidget {
  const CirclePlaceholder(
      {super.key,
      required this.level,
      this.ringIndex = 0,
      this.difficulty = 0,
      this.onCompleted,
      this.onMistake,
      this.gemSize = 30});

  final LevelModel level;
  final int ringIndex;
  final int difficulty;
  final double? gemSize;
  final Function()? onCompleted;
  final Function()? onMistake;

  @override
  State<CirclePlaceholder> createState() => _CirclePlaceholderState();
}

class _CirclePlaceholderState extends State<CirclePlaceholder> {
  double initialDisplacement = 80;
  double displacement = 70;
  double cx = 0;
  double cy = 0;
  double radius = 0;
  double r2 = 36;
  int numberOfPods = 1;
  double angleStep = 4;
  Map<int, dynamic> dropData = {};
  Map<int, dynamic> adjacentPairs = {};
  List<GlobalKey> arcsKeys = [];
  List<AnimatedArc> arcs = [];

  double ringWidth = 6;

  int frequentColorIndex = -1;

  @override
  void initState() {
    r2 = (widget.gemSize ?? 30) + 6;
    radius = initialDisplacement + widget.ringIndex * displacement;
    cx = cy = radius / 2;
    numberOfPods = widget.difficulty + 4;
    angleStep = 2 * pi / numberOfPods;

    for (var i = 0; i < numberOfPods; i++) {
      dropData[i] = null;
      adjacentPairs[i] = null;
    }
    // adjacentPairs = List.generate(numberOfPods, (_) => []);
    arcs = List.generate(
      numberOfPods,
      (index) {
        Offset coords = getCoords(index);
        Offset coords2 = getCoords(index + 1);

        GlobalKey k = GlobalKey();
        arcsKeys.add(k);

        return AnimatedArc(
          key: k,
          x1: coords.dx,
          y1: coords.dy,
          x2: coords2.dx,
          y2: coords2.dy,
          colorIndex: frequentColorIndex,
          radius: radius,
          radius2: r2,
        );
      },
    );

    super.initState();
  }

  int lastX = 0, lastY = 0;

  @override
  Widget build(BuildContext context) {
    Color ringColor = Colors.grey.withOpacity(0.5);
    if (frequentColorIndex > -1) {
      ringColor = colors[frequentColorIndex].withOpacity(0.5);
    }

    return Center(
      child: SizedBox(
        width: radius + r2,
        height: radius + r2,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: ringWidth,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),

            // Arcs
            ...arcs,

            // Drop target Placeholders
            ...List.generate(
              numberOfPods,
              (index) {
                double y = (radius / 2) +
                    (radius / 2) * sin(2 * pi * index / numberOfPods);
                double x = (radius / 2) +
                    (radius / 2) * cos(2 * pi * index / numberOfPods);

                // print("x: $x, y: $y");

                LevelModel _level = widget.level;
                int i = widget.ringIndex;

                bool isFrozen = false;
                if (_level.freez != null && _level.freez!.length > i) {
                  // print(_level.freez![i]);
                  // print(_level.freez![i].runtimeType);

                  if (_level.freez![i].runtimeType == int) {
                    isFrozen = _level.freez![i] as int == 1;
                  } else {
                    isFrozen = _level.freez![i].contains(index + 1);
                  }
                }

                bool isRocked = false;
                if (_level.rock != null && _level.rock!.length > i) {
                  // print(_level.rock![i]);
                  // print(_level.rock![i].runtimeType);
                  if (_level.rock![i].runtimeType == int) {
                    isRocked = _level.rock![i] as int == 1;
                  } else {
                    isRocked = _level.rock![i].contains(index + 1);
                  }
                }

                return Positioned(
                  left: x,
                  top: y,
                  child: DropTargetWidget(
                    r: r2,
                    frozen: isFrozen,
                    frozenThreshold: 3,
                    rocked: isRocked,
                    rockedThreshold: 3,
                    onMistake: widget.onMistake,
                    onDrop: (colorIndex) {
                      dropData[index] = {
                        "colorIndex": colorIndex,
                        "x": x,
                        "y": y
                      };
                      setState(() {
                        setFrequentColorIndex();
                      });
                      checkCompletion();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  setFrequentColorIndex() {
    final dropSet = dropData.values
        .where(
          (element) => element != null,
        )
        .toList();
    if (dropSet.isNotEmpty) {
      frequentColorIndex = dropSet
          .map((e) => e["colorIndex"])
          .toList()
          .fold<Map<int, int>>({}, (map, number) {
            map[number] = (map[number] ?? 0) + 1;
            return map;
          })
          .entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
  }

  // get x, y coordinates
  getCoords(index) {
    double y = (radius / 2) + (radius / 2) * sin(2 * pi * index / numberOfPods);
    double x = (radius / 2) + (radius / 2) * cos(2 * pi * index / numberOfPods);

    return Offset(x, y);
  }

  checkCompletion() {
    if (dropData.isEmpty) {
      return;
    }

    if (dropData.length > 2) {
      // check adjacent pairs
      for (var i = 0; i < dropData.length - 1; i++) {
        final a = dropData[i] ?? false;
        final b = dropData[i + 1] ?? false;
        if (a != false &&
            b != false &&
            a["colorIndex"] == frequentColorIndex &&
            a["colorIndex"] == b["colorIndex"]) {
          adjacentPairs[i] = [a, b];
        } else {
          adjacentPairs[i] = null;
        }
      }

      // check first and last elements
      final a = dropData[0] ?? false;
      final b = dropData[numberOfPods - 1] ?? false;
      if (a != false &&
          b != false &&
          a["colorIndex"] == frequentColorIndex &&
          a["colorIndex"] == b["colorIndex"]) {
        adjacentPairs[numberOfPods - 1] = [a, b];
      } else {
        adjacentPairs[numberOfPods - 1] = null;
      }
    }

    for (int i in adjacentPairs.keys) {
      if (adjacentPairs[i] != null && adjacentPairs[i].isNotEmpty) {
        _AnimatedArcsState state =
            (arcsKeys[i].currentState! as _AnimatedArcsState);
        state.colorIndex = frequentColorIndex;
        state.forward();
      } else {
        _AnimatedArcsState state =
            (arcsKeys[i].currentState! as _AnimatedArcsState);
        state.reverse().then((value) => state.colorIndex = -1);
      }
    }

    if (adjacentPairs.values.where((e) => e == null).isEmpty) {
      widget.onCompleted?.call();
    }
  }
}

class AnimatedArc extends StatefulWidget {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double radius;
  final double radius2;
  final int colorIndex;

  const AnimatedArc({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.radius,
    required this.radius2,
    required this.colorIndex,
    super.key,
  });

  @override
  _AnimatedArcsState createState() => _AnimatedArcsState();

  // get current state
  _AnimatedArcsState get currentState => _AnimatedArcsState();
}

class _AnimatedArcsState extends State<AnimatedArc>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  late int _colorIndex;

  @override
  void initState() {
    colorIndex = widget.colorIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..stop();
    super.initState();
  }

  TickerFuture forward() {
    return _controller!.forward();
  }

  TickerFuture reverse() {
    return _controller!.reverse();
  }

  int get colorIndex => _colorIndex;
  set colorIndex(int value) {
    _colorIndex = value;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.radius, widget.radius),
          painter: CircleFillerPainter(
            x1: widget.x1,
            y1: widget.y1,
            x2: widget.x2,
            y2: widget.y2,
            colorIndex: colorIndex,
            radius: widget.radius,
            radius2: widget.radius2,
            progress: _controller!.value,
          ),
        );
      },
    );
  }
}

class CircleFillerPainter extends CustomPainter {
  final double radius;
  final double radius2;
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final int colorIndex;
  final double progress;

  CircleFillerPainter({
    required this.radius,
    required this.radius2,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.colorIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color color = Colors.pinkAccent;
    if (colorIndex > -1) {
      color = colors[colorIndex];
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..colorFilter = ColorFilter.mode(
        color,
        BlendMode.softLight,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(3));

    final path = Path();

    final tmpX1 = x1 + (radius2 / 2);
    final tmpY1 = y1 + (radius2 / 2);
    final tmpX2 = x2 + (radius2 / 2);
    final tmpY2 = y2 + (radius2 / 2);

    path.moveTo(tmpX1, tmpY1);
    path.arcToPoint(
      Offset(tmpX2, tmpY2),
      radius: Radius.circular(radius / 2),
      clockwise: true,
    );

    // canvas.drawPath(path, paint);
    // Measure the path and draw only a portion of it based on progress
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  bool shouldRepaint(CircleFillerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
