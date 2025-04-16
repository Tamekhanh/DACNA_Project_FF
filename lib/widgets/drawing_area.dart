import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/frame_data.dart';
import 'drawing_painter.dart';

class DrawingArea extends StatefulWidget {
  final FrameData? initialFrame;
  final bool isPlaying;
  final int currentFrameIndex;
  final List<FrameData> allFrames;
  final Function(FrameData) onSave;
  final VoidCallback onClear;

  final Color selectedColor;
  final double strokeWidth;
  final bool isEraserMode;
  final bool showOnionSkin;

  const DrawingArea({
    super.key,
    required this.initialFrame,
    required this.isPlaying,
    required this.currentFrameIndex,
    required this.allFrames,
    required this.onSave,
    required this.selectedColor,
    required this.strokeWidth,
    required this.isEraserMode,
    required this.onClear,
    required this.showOnionSkin,
  });

  @override
  State<DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  final GlobalKey repaintKey = GlobalKey();
  List<List<Offset?>> strokes = [];
  List<Color> strokeColors = [];
  List<double> strokeWidths = [];
  Rect? drawingArea;

  @override
  void initState() {
    super.initState();
    _initDrawingData();
  }

  @override
  void didUpdateWidget(covariant DrawingArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFrame != oldWidget.initialFrame) {
      _initDrawingData();
    }
  }

  void _initDrawingData() {
    strokes = widget.initialFrame?.strokes.map((s) => List<Offset?>.from(s)).toList() ?? [];
    strokeColors = widget.initialFrame?.strokeColors.toList() ?? [];
    strokeWidths = widget.initialFrame?.strokeWidths.toList() ?? [];
  }

  bool _isInDrawingArea(Offset point) => drawingArea?.contains(point) ?? false;

  Future<Uint8List> _captureImage() async {
    RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _saveFrame() async {
    final imageBytes = await _captureImage();
    final frame = FrameData(
      image: imageBytes,
      strokes: strokes.map((s) => List<Offset?>.from(s)).toList(),
      strokeColors: List.from(strokeColors),
      strokeWidths: List.from(strokeWidths),
    );
    widget.onSave(frame);
  }

  void _clearCanvas() {
    setState(() {
      strokes.clear();
      strokeColors.clear();
      strokeWidths.clear();
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Stack(
          children: [
            if (!widget.isPlaying && widget.showOnionSkin) ...[
              if (widget.currentFrameIndex > 0)
                Positioned.fill(
                  child: Image.memory(
                    widget.allFrames[widget.currentFrameIndex - 1].image,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.3),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              if (widget.currentFrameIndex > 1)
                Positioned.fill(
                  child: Image.memory(
                    widget.allFrames[widget.currentFrameIndex - 2].image,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.1),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
            ],
            if (!widget.isPlaying)
              GestureDetector(
                onPanStart: (details) {
                  if (_isInDrawingArea(details.localPosition)) {
                    setState(() {
                      strokes.add([details.localPosition]);
                      strokeColors.add(widget.isEraserMode ? Colors.white : widget.selectedColor);
                      strokeWidths.add(widget.strokeWidth);
                    });
                  }
                },
                onPanUpdate: (details) {
                  if (strokes.isNotEmpty && _isInDrawingArea(details.localPosition)) {
                    setState(() => strokes.last.add(details.localPosition));
                  }
                },
                onPanEnd: (_) {
                  if (strokes.isNotEmpty) strokes.last.add(null);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final renderBox = context.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        drawingArea = renderBox.size.isEmpty ? null : Offset.zero & renderBox.size;
                      }
                    });
                    return RepaintBoundary(
                      key: repaintKey,
                      child: CustomPaint(
                        painter: DrawingPainter(strokes, strokeColors, strokeWidths),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
