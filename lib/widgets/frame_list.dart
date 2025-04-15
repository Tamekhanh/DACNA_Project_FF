import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/frame_data.dart';

class FrameListWidget extends StatelessWidget {
  final List<FrameData> frames;
  final void Function(int index) onLoad;
  final void Function(int index) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  const FrameListWidget({
    super.key,
    required this.frames,
    required this.onLoad,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: frames.length,
      onReorder: onReorder,
      padding: const EdgeInsets.all(12), // Padding toàn bộ danh sách
      itemBuilder: (context, index) {
        final frame = frames[index];
        return Padding(
          key: ValueKey(index),
          padding: const EdgeInsets.symmetric(vertical: 8), // Khoảng cách giữa các frame
          child: GestureDetector(
            onTap: () => onLoad(index),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Bo góc ảnh
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: frame.image.isNotEmpty
                        ? Image.memory(
                      frame.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.broken_image),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => onDelete(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
