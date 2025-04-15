import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/frame_data.dart';
import 'bottom_toolbar.dart';

class DrawingCanvas extends StatefulWidget {
  final FrameData? initialFrame;
  final Function(FrameData) onSave;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final VoidCallback onClear;
  final TextEditingController fpsController;
  final List<FrameData> allFrames;
  final int currentFrameIndex;

  const DrawingCanvas({
    super.key,
    required this.initialFrame,
    required this.onSave,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onClear,
    required this.fpsController,
    required this.allFrames,
    required this.currentFrameIndex,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final GlobalKey repaintKey = GlobalKey();
  late List<List<Offset?>> strokes;
  late List<Color> strokeColors;
  late List<double> strokeWidths;
  Color selectedColor = Colors.blue;
  bool isEraserMode = false;
  double strokeWidth = 5.0;
  Rect? drawingArea;
  int fps = 12;
  int currentFrame = 0;
  Timer? playbackTimer;
  List<List<List<Offset?>>> undoStack = [];
  List<List<List<Offset?>>> redoStack = [];
  bool showOnionSkin = true;
  FrameData? currentFrameData;

  @override
  void initState() {
    super.initState();
    widget.fpsController.addListener(updateFPS);
    _initializeDrawingData();
  }

  void _initializeDrawingData() {
    strokes = widget.initialFrame?.strokes.map((s) => List<Offset?>.from(s)).toList() ?? [];
    strokeColors = widget.initialFrame?.strokeColors.toList() ?? [];
    strokeWidths = widget.initialFrame?.strokeWidths.toList() ?? [];
    currentFrameData = widget.initialFrame;
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialFrame != oldWidget.initialFrame) {
      _saveCurrentStateToUndoStack();
      _initializeDrawingData();
    }

    if (widget.isPlaying) {
      _startPlayback();
    } else {
      _stopPlayback();
    }
  }

  Future<Uint8List> _resizeTo16_9(ui.Image image) async {
    final width = image.width;
    final targetHeight = (width * 9 / 16).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (image.height > targetHeight) {
      final cropY = (image.height - targetHeight) ~/ 2;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, cropY.toDouble(), width.toDouble(), targetHeight.toDouble()),
        Rect.fromLTWH(0, 0, width.toDouble(), targetHeight.toDouble()),
        Paint(),
      );
    } else {
      final targetWidth = (image.height * 16 / 9).round();
      canvas.drawRect(
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), image.height.toDouble()),
        Paint()..color = Colors.white,
      );
      final offsetX = (targetWidth - image.width) ~/ 2;
      canvas.drawImage(
        image,
        Offset(offsetX.toDouble(), 0),
        Paint(),
      );
    }

    final newImage = await recorder.endRecording().toImage(
      image.width,
      targetHeight,
    );
    final byteData = await newImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> captureImage() async {
    RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    return await _resizeTo16_9(image);
  }

  void _saveCurrentStateToUndoStack() {
    undoStack.add(strokes.map((s) => List<Offset?>.from(s)).toList());
    redoStack.clear();
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(strokes.map((s) => List<Offset?>.from(s)).toList());
      strokes = undoStack.removeLast().map((s) => List<Offset?>.from(s)).toList();
      setState(() {});
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(strokes.map((s) => List<Offset?>.from(s)).toList());
      strokes = redoStack.removeLast().map((s) => List<Offset?>.from(s)).toList();
      setState(() {});
    }
  }

  Future<void> saveImage() async {
    final pngBytes = await captureImage();
    final newFrame = FrameData(
      image: pngBytes,
      strokes: strokes.map((s) => List<Offset?>.from(s)).toList(),
      strokeColors: List.from(strokeColors),
      strokeWidths: List.from(strokeWidths),
    );

    widget.onSave(newFrame);

    if (widget.initialFrame == null) {
      setState(() {
        strokes.clear();
        strokeColors.clear();
        strokeWidths.clear();
        undoStack.clear();
        redoStack.clear();
      });
    }
  }

  void _startPlayback() {
    _stopPlayback();
    if (!widget.isPlaying) return;

    playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (timer) {
      if (!widget.isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        currentFrame = (currentFrame + 1) % widget.allFrames.length;
        currentFrameData = widget.allFrames[currentFrame];
      });
    });
  }

  void _stopPlayback() => playbackTimer?.cancel();

  void updateFPS() {
    final value = int.tryParse(widget.fpsController.text);
    if (value != null && value > 0 && value <= 60) {
      setState(() => fps = value);
      if (widget.isPlaying) {
        _stopPlayback();
        _startPlayback();
      }
    }
  }

  bool _isInDrawingArea(Offset point) => drawingArea?.contains(point) ?? false;

  void clearCurrentDrawing() {
    _saveCurrentStateToUndoStack();
    setState(() {
      strokes.clear();
      strokeColors.clear();
      strokeWidths.clear();
    });
    widget.onClear();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => setState(() => selectedColor = color),
            enableAlpha: false,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBrushSizeDialog() {
    double tempValue = strokeWidth; // Biến tạm để điều khiển slider mượt

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Brush size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: tempValue,
                min: 1,
                max: 50,
                divisions: 49,
                label: tempValue.round().toString(),
                onChanged: (value) {
                  setStateDialog(() => tempValue = value); // Cập nhật trong dialog
                },
              ),
              Text(
                '${tempValue.round()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => strokeWidth = tempValue); // Cập nhật thật khi nhấn OK
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                children: [
                  // Onion skin (frame trước) — luôn kiểm tra an toàn
                  if (!widget.isPlaying && showOnionSkin) ...[
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

                  // Hiển thị frame đang phát khi playback
                  if (widget.isPlaying && currentFrameData != null)
                    Positioned.fill(
                      child: Image.memory(
                        currentFrameData!.image,
                        fit: BoxFit.contain,
                      ),
                    ),

                  // Cho phép vẽ nếu không đang play
                  if (!widget.isPlaying)
                    GestureDetector(
                      onPanStart: (details) {
                        if (_isInDrawingArea(details.localPosition)) {
                          _saveCurrentStateToUndoStack();
                          setState(() {
                            strokes.add([details.localPosition]);
                            strokeColors.add(isEraserMode ? Colors.white : selectedColor);
                            strokeWidths.add(strokeWidth);
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
                              drawingArea = renderBox.size.isEmpty
                                  ? null
                                  : Offset.zero & renderBox.size;
                            }
                          });
                          return RepaintBoundary(
                            key: repaintKey,
                            child: CustomPaint(
                              painter: _DrawingPainter(strokes, strokeColors, strokeWidths),
                              size: Size.infinite,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),

            ),
          ),
        ),
        BottomToolbar(
          selectedColor: selectedColor,
          isEraserMode: isEraserMode,
          strokeWidth: strokeWidth,
          isPlaying: widget.isPlaying,
          showOnionSkin: showOnionSkin,
          onToggleEraser: () => setState(() => isEraserMode = !isEraserMode),
          onColorTap: _showColorPicker,
          onBrushSizeTap: _showBrushSizeDialog,
          onSave: saveImage,
          onPlay: widget.onTogglePlayback,
          onClear: clearCurrentDrawing,
          onUndo: undo,
          onRedo: redo,
          onToggleOnionSkin: () => setState(() => showOnionSkin = !showOnionSkin),
          onFpsChanged: (value) {
            final fpsValue = int.tryParse(value) ?? 12;
            setState(() => fps = fpsValue.clamp(1, 60));
          },
          fpsValue: fps.toString(),
        ),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Color> colors;
  final List<double> widths;

  _DrawingPainter(this.strokes, this.colors, this.widths);

  @override
  void paint(Canvas canvas, Size size) {
    for (int j = 0; j < strokes.length; j++) {
      final paint = Paint()
        ..color = colors[j]
        ..strokeCap = StrokeCap.round
        ..strokeWidth = widths[j];

      for (int i = 0; i < strokes[j].length - 1; i++) {
        if (strokes[j][i] != null && strokes[j][i + 1] != null) {
          canvas.drawLine(strokes[j][i]!, strokes[j][i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
