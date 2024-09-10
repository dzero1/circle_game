import 'package:circle_game/component/drag_target.dart';
import 'package:flutter/material.dart';

class DropTargetWidget extends StatefulWidget {
  const DropTargetWidget({
    super.key,
    required this.r,
    this.child,
    this.onDrop,
    this.onMistake,
    this.frozen = false,
    this.frozenThreshold = 3,
    this.rocked = false,
    this.rockedThreshold = 3,
  });
  final double r;
  final Widget? child;
  final Function(int colorIndex)? onDrop;
  final Function()? onMistake;

  final bool? frozen;
  final int? frozenThreshold;

  final bool? rocked;
  final int? rockedThreshold;

  @override
  State<DropTargetWidget> createState() => _DropTargetWidgetState();
}

class _DropTargetWidgetState extends State<DropTargetWidget> {
  Droplet? droppedItem;
  GlobalKey gKey = GlobalKey();

  Color ringColor = const Color.fromARGB(255, 179, 71, 91);
  Color ringBorderColor =
      const Color.fromARGB(255, 154, 40, 61).withOpacity(0.5);
  double ringWidth = 2;

  bool? frozen = false;
  int? frozenThreshold = 3;
  bool? rocked = false;
  int? rockedThreshold = 3;

  @override
  void initState() {
    frozen = widget.frozen;
    frozenThreshold = widget.frozenThreshold;
    rocked = widget.rocked;
    rockedThreshold = widget.rockedThreshold;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        Widget droplet = candidateData.isNotEmpty
            ? Droplet(colorIndex: candidateData.first as int)
            : droppedItem ?? widget.child ?? Container();

        return SizedBox(
          width: widget.r,
          height: widget.r,
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: widget.r,
                  height: widget.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/background/gem_holder.png"),
                      fit: BoxFit.cover,
                      isAntiAlias: true,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (frozen == true && frozenThreshold! > 0)
                        Center(
                          child: FrozenWidget(
                            width: widget.r,
                            height: widget.r,
                            threshold: frozenThreshold!,
                          ),
                        ),
                      if (rocked == true && rockedThreshold! > 0)
                        Center(
                          child: RockWidget(
                            width: widget.r,
                            height: widget.r,
                            threshold: rockedThreshold!,
                          ),
                        ),
                    ],
                  ),
                ),
                Center(child: droplet),
              ],
            ),
          ),
        );
      },
      onAcceptWithDetails: (DragTargetDetails<Object> details) {
        if (rocked == true && rockedThreshold! > 0) {
          rockedThreshold = rockedThreshold! - 1;
          return;
        } else if (frozen == true && frozenThreshold! > 0) {
          frozenThreshold = frozenThreshold! - 1;
          return;
        }
        if (droppedItem != null && details.data != droppedItem!.colorIndex) {
          widget.onMistake?.call();
        }
        droppedItem = Droplet(key: gKey, colorIndex: details.data as int);
        widget.onDrop?.call(details.data as int);
      },
    );
  }
}

class FrozenWidget extends StatefulWidget {
  const FrozenWidget(
      {super.key,
      required this.width,
      required this.height,
      this.threshold = 1});

  final double width;
  final double height;
  final int threshold;

  @override
  State<FrozenWidget> createState() => _FrozenWidgetState();
}

class _FrozenWidgetState extends State<FrozenWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: const AssetImage("assets/background/freezed.png"),
          opacity: 0.5 + (widget.threshold / 6),
          fit: BoxFit.cover,
          isAntiAlias: true,
        ),
      ),
    );
  }
}

class RockWidget extends StatefulWidget {
  const RockWidget(
      {super.key,
      required this.width,
      required this.height,
      this.threshold = 1});

  final double width;
  final double height;
  final int threshold;

  @override
  State<RockWidget> createState() => _RockWidgetState();
}

class _RockWidgetState extends State<RockWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: const AssetImage("assets/background/rock.png"),
          opacity: 0.5 + (widget.threshold / 6),
          fit: BoxFit.cover,
          isAntiAlias: true,
        ),
      ),
    );
  }
}
