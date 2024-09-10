import 'package:circle_game/helpers/sound_manager.dart';
import 'package:flutter/material.dart';

enum ImageButtonSize { small, large, medium }

class ImageButton extends StatefulWidget {
  final String imagePath;
  final ImageButtonSize size;
  final bool stateButton;
  final Function()? onPressed;

  const ImageButton(
      {required this.imagePath,
      this.onPressed,
      this.size = ImageButtonSize.large,
      this.stateButton = false,
      super.key});

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlignmentGeometry? alignment =
        _isPressed ? Alignment.centerRight : Alignment.centerLeft;

    double btnWidth = 200;
    double btnHeight = 70;
    switch (widget.size) {
      case ImageButtonSize.medium:
        btnWidth = 46;
        btnHeight = 46;
        break;
      case ImageButtonSize.small:
        btnWidth = 35;
        btnHeight = 35;
        break;
      default:
    }

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) async {
        await audioController.playSound('assets/audio/click.mp3');
        setState(() {
          _isPressed = widget.stateButton ? !_isPressed : true;
        });
      },
      onTapUp: (_) => setState(() {
        if (!widget.stateButton) _isPressed = false;
      }),
      onTapCancel: () => setState(() {
        if (!widget.stateButton) _isPressed = false;
      }),
      child: Container(
        width: btnWidth, // Set the appropriate width for your image
        height: btnHeight, // Set the appropriate height for your image
        decoration: BoxDecoration(
          // color: Colors.amber,
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
            alignment: alignment,
          ),
        ),
      ),
    );
  }
}
