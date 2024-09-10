import 'dart:math';
import 'package:circle_game/helpers/game_elements.dart';
import 'package:flutter/material.dart';

class DragTargetWidget extends StatefulWidget {
  const DragTargetWidget(
      {super.key, this.size = 30, this.gemSet = const [1, 2, 3, 4, 5, 6]});

  final double? size;
  final List? gemSet;

  @override
  State<DragTargetWidget> createState() => _DragTargetWidgetState();
}

class _DragTargetWidgetState extends State<DragTargetWidget> {
  @override
  Widget build(BuildContext context) {
    int index = Random().nextInt(widget.gemSet!.length);
    int colorIndex = widget.gemSet![index] - 1;

    Droplet drop = Droplet(
      colorIndex: colorIndex,
      size: widget.size ?? 30,
    );

    return GestureDetector(
      onDoubleTap: () => setState(() {}),
      child: Draggable(
        data: drop.colorIndex,
        // onDragStarted: () => print('drag started'),
        onDragCompleted: () {
          setState(() {});
        },
        feedback: drop,
        childWhenDragging: drop,
        child: drop,
      ),
    );
  }
}

class Droplet extends StatelessWidget {
  const Droplet({super.key, required this.colorIndex, this.size});

  final int colorIndex;
  final double? size;

  @override
  Widget build(BuildContext context) {
    print(gems[colorIndex]);
    return SizedBox(
      width: size ?? 30,
      height: size ?? 30,
      child: gems[colorIndex],
    );
  }
}
