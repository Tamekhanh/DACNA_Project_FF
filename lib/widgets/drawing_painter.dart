import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Color> colors;
  final List<double> widths;

  DrawingPainter(this.strokes, this.colors, this.widths);

  @override
  void paint(Canvas canvas, Size size) {
    for (int j = 0; j < strokes.length; j++) {
      final paint = Paint()
        ..color = colors[j]
        ..strokeCap = StrokeCap.round
        ..strokeWidth = widths[j];

      for (int i = 0; i < strokes[j].length - 1; i++) {
        final p1 = strokes[j][i];
        final p2 = strokes[j][i + 1];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
