import 'dart:typed_data';
import 'package:flutter/material.dart';

class FrameData {
  final Uint8List image;
  final List<List<Offset?>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeWidths;

  FrameData({
    required this.image,
    required this.strokes,
    required this.strokeColors,
    required this.strokeWidths,
  });

  FrameData copyWith({
    Uint8List? image,
    List<List<Offset?>>? strokes,
    List<Color>? strokeColors,
    List<double>? strokeWidths,
  }) {
    return FrameData(
      image: image ?? this.image,
      strokes: strokes ?? List.from(this.strokes),
      strokeColors: strokeColors ?? List.from(this.strokeColors),
      strokeWidths: strokeWidths ?? List.from(this.strokeWidths),
    );
  }
}