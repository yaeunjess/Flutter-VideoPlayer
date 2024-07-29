import 'package:flutter/material.dart';

class CustomTimeText extends StatelessWidget {
  final Duration duration;

  const CustomTimeText({
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${duration.inMinutes.toString().padLeft(2,'0')}:${(duration.inSeconds % 60).toString().padLeft(2,'0')}',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}
