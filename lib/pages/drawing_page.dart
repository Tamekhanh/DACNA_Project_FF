import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_testing/models/frame_data.dart';
import 'package:flutter_testing/widgets/drawing_canvas.dart';
import 'package:flutter_testing/widgets/frame_list.dart';
import 'package:transparent_image/transparent_image.dart'; // <-- THÊM

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final List<FrameData> _frames = [];
  int? _editingFrameIndex;
  bool _isPlaying = false;
  bool _isPanelVisible = true;
  Color _selectedColor = Colors.blue;
  double _strokeWidth = 5.0;
  bool _isEraserMode = false;
  final TextEditingController _fpsController = TextEditingController(
    text: "12",
  );

  @override
  void initState() {
    super.initState();
    _createInitialBlankFrame();
  }

  void _createInitialBlankFrame() {
    final blankFrame = FrameData(
      image: Uint8List.fromList(kTransparentImage), // <-- ảnh trong suốt
      strokes: [],
      strokeColors: [],
      strokeWidths: [],
    );

    _frames.add(blankFrame);
    _editingFrameIndex = 0;
  }

  void _loadFrame(int index) {
    if (index >= 0 && index < _frames.length) {
      setState(() {
        _editingFrameIndex = index;
      });
    }
  }

  void _saveFrame(FrameData newFrame) {
    setState(() {
      if (_editingFrameIndex != null) {
        _frames[_editingFrameIndex!] = newFrame.copyWith();
      } else {
        _frames.add(newFrame.copyWith());
      }

      // Tạo frame trống mới có lớp phủ từ ảnh vừa lưu
      final nextBlankFrame = FrameData(
        image: newFrame.image, // lớp phủ dùng ảnh trước
        strokes: [],
        strokeColors: [],
        strokeWidths: [],
      );

      _frames.add(nextBlankFrame);
      _editingFrameIndex = _frames.length - 1; // chuyển sang frame trống mới
    });
  }

  void _deleteFrame(int index) {
    if (index >= 0 && index < _frames.length) {
      setState(() {
        _frames.removeAt(index);
        if (_editingFrameIndex == index) {
          _editingFrameIndex = null;
        } else if (_editingFrameIndex != null && _editingFrameIndex! > index) {
          _editingFrameIndex = _editingFrameIndex! - 1;
        }
      });
    }
  }

  void _clearCurrentDrawing() {
    setState(() => _editingFrameIndex = null);
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying && _frames.isEmpty) {
        _isPlaying = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No frames to play')));
      }
    });
  }

  void _togglePanel() => setState(() => _isPanelVisible = !_isPanelVisible);

  @override
  void dispose() {
    _fpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF43474E),
        title: const Text(
          'Drawing Animation',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE1E2E9)
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            color: Color(0xFFE1E2E9),
            onPressed: _togglePanel,
            tooltip: 'Toggle Frames Panel',
          ), //Nút hiện/ẩn danh sách frame
          IconButton(
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            color: Color(0xFFE1E2E9),
            onPressed: _frames.isNotEmpty ? _togglePlayback : null,
            tooltip: _isPlaying ? 'Stop' : 'Play',
          ), //Nút phát/dừng
          IconButton(
            icon: const Icon(Icons.clear),
            color: Color(0xFFE1E2E9),
            onPressed: _clearCurrentDrawing,
            tooltip: 'Clear Drawing',
          ), //Nút xóa hình vẽ
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            color: Color(0xFF43474E),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add settings logic
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add save logic
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add share logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.undo),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add share logic
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add redo logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add select_all logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.format_color_fill),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add color logic
                ),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.colorize),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.square_outlined),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.brightness_1_outlined),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                IconButton(
                  icon: const Icon(Icons.change_history),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.mic),
                  color: Color(0xFFE1E2E9),
                  onPressed: () {}, // TODO: Add logic
                ),
              ],
            ),
          ),
          // Body chính
          Expanded(
            child: Row(
              children: [
                if (_isPanelVisible)
                  Container(
                    margin: const EdgeInsets.only(right: 2, top: 2),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF43474E),
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Frames (${_frames.length})',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold,
                            color: Color(0xFFE1E2E9),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FrameListWidget(
                            frames: _frames,
                            onLoad: _loadFrame,
                            onDelete: _deleteFrame,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = _frames.removeAt(oldIndex);
                                _frames.insert(newIndex, item);

                                if (_editingFrameIndex == oldIndex) {
                                  _editingFrameIndex = newIndex;
                                } else if (_editingFrameIndex != null) {
                                  if (_editingFrameIndex! > oldIndex &&
                                      _editingFrameIndex! <= newIndex) {
                                    _editingFrameIndex =
                                        _editingFrameIndex! - 1;
                                  } else if (_editingFrameIndex! >= newIndex &&
                                      _editingFrameIndex! < oldIndex) {
                                    _editingFrameIndex =
                                        _editingFrameIndex! + 1;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: DrawingCanvas(
                    key: ValueKey(_editingFrameIndex),
                    initialFrame:
                        _editingFrameIndex != null
                            ? _frames[_editingFrameIndex!].copyWith()
                            : null,
                    currentFrameIndex: _editingFrameIndex ?? 0,
                    allFrames: _frames,
                    onSave: _saveFrame,
                    isPlaying: _isPlaying,
                    onTogglePlayback: _togglePlayback,
                    onClear: _clearCurrentDrawing,
                    fpsController: _fpsController,

                    // Giữ lại trạng thái từ frame này sang frame khác
                    selectedColor: _selectedColor,
                    strokeWidth: _strokeWidth,
                    isEraserMode: _isEraserMode,
                    onColorChanged:
                        (color) => setState(() => _selectedColor = color),
                    onStrokeWidthChanged:
                        (width) => setState(() => _strokeWidth = width),
                    onEraserModeChanged:
                        (value) => setState(() => _isEraserMode = value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
