import 'package:flutter/material.dart';

enum StarsSize { small, large }

class AnimatedStars extends StatefulWidget {
  const AnimatedStars(this.stars, {super.key, this.size = StarsSize.large});

  final int stars;
  final StarsSize size;

  @override
  State<AnimatedStars> createState() => _AnimatedStarsState();
}

class _AnimatedStarsState extends State<AnimatedStars> {
  @override
  Widget build(BuildContext context) {
    double largeStar = 50;
    double smallStar = 35;

    switch (widget.size) {
      case StarsSize.small:
        largeStar = 38;
        smallStar = 28;
        break;
      default:
    }

    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (i) => RotatedBox(
            quarterTurns: i < 1
                ? -1
                : i == 1
                    ? 0
                    : 1,
            child: Icon(
              Icons.star,
              color:
                  widget.stars >= i + 1 ? Colors.yellowAccent : Colors.black12,
              size: i == 1 ? largeStar : smallStar,
            ),
          ),
        ),
      ),
    );
  }
}
