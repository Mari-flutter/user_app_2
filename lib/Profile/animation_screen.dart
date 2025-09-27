import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const AnimatedGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: widget.colors,
              stops: List.generate(
                widget.colors.length,
                    (index) => index / (widget.colors.length - 1),
              ),
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 - _controller.value * 2, 0),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(
                color: Colors.white),
          ),
        );
      },
    );
  }
}