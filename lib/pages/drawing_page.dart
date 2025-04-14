import 'package:flutter/material.dart';
import 'package:flutter_testing/models/frame_data.dart';
import 'package:flutter_testing/widgets/drawing_canvas.dart';
import 'package:flutter_testing/widgets/frame_list.dart';

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
  final TextEditingController _fpsController = TextEditingController(text: "12");

  @override
  void dispose() {
    _fpsController.dispose();
    super.dispose();
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
      _editingFrameIndex = null;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No frames to play')),
        );
      }
    });
  }

  void _togglePanel() => setState(() => _isPanelVisible = !_isPanelVisible);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎨 Drawing Animation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _togglePanel,
            tooltip: 'Toggle Frames Panel',
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: _frames.isNotEmpty ? _togglePlayback : null,
            tooltip: _isPlaying ? 'Stop' : 'Play',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCurrentDrawing,
            tooltip: 'Clear Drawing',
          ),
        ],
      ),
      body: Row(
        children: [
          if (_isPanelVisible)
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                              _editingFrameIndex = _editingFrameIndex! - 1;
                            } else if (_editingFrameIndex! >= newIndex &&
                                _editingFrameIndex! < oldIndex) {
                              _editingFrameIndex = _editingFrameIndex! + 1;
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
              initialFrame: _editingFrameIndex != null
                  ? _frames[_editingFrameIndex!].copyWith()
                  : null,
              currentFrameIndex: _editingFrameIndex ?? 0,
              allFrames: _frames,
              onSave: _saveFrame,
              isPlaying: _isPlaying,
              onTogglePlayback: _togglePlayback,
              onClear: _clearCurrentDrawing,
              fpsController: _fpsController,
            ),

          ),
        ],
      ),
    );
  }
}