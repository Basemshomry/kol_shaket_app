import 'package:flutter/material.dart';

class AnimatedStatNumber extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const AnimatedStatNumber({
    super.key,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: style,
    );
  }
}