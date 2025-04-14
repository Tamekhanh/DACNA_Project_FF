import 'package:flutter/material.dart';
import 'package:flutter_testing/models/frame_data.dart';

class FrameListWidget extends StatefulWidget {
  final List<FrameData> frames;
  final ValueChanged<int> onLoad;
  final ValueChanged<int> onDelete;
  final ReorderCallback onReorder;

  const FrameListWidget({
    super.key,
    required this.frames,
    required this.onLoad,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  State<FrameListWidget> createState() => _FrameListWidgetState();
}

class _FrameListWidgetState extends State<FrameListWidget> {
  int? _hoveredIndex;
  int? _draggedIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.frames.isEmpty
        ? Center(
      child: Text(
        "No frames yet",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    )
        : ReorderableListView.builder(
      scrollController: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: widget.frames.length,
      onReorder: (oldIndex, newIndex) {
        widget.onReorder(oldIndex, newIndex);
        setState(() => _draggedIndex = null);
      },
      onReorderStart: (index) => setState(() => _draggedIndex = index),
      itemBuilder: (context, index) {
        final frame = widget.frames[index];
        return _FrameListItem(
          key: ValueKey('frame_${frame.image.hashCode}'),
          frame: frame,
          index: index,
          isHovered: _hoveredIndex == index,
          isDragged: _draggedIndex == index,
          onLoad: () => widget.onLoad(index),
          onDelete: () => widget.onDelete(index),
          onHover: (hovering) => setState(
                () => _hoveredIndex = hovering ? index : null,
          ),
        );
      },
    );
  }
}

class _FrameListItem extends StatelessWidget {
  final FrameData frame;
  final int index;
  final bool isHovered;
  final bool isDragged;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final ValueChanged<bool> onHover;

  const _FrameListItem({
    required super.key,
    required this.frame,
    required this.index,
    required this.isHovered,
    required this.isDragged,
    required this.onLoad,
    required this.onDelete,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isDragged
              ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          )
              : null,
          boxShadow: isHovered
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Frame Thumbnail
            GestureDetector(
              onTap: onLoad,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.memory(
                    frame.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Frame Number
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Delete Button (visible on hover or drag)
            // Delete Button (always visible)
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onDelete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
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
  }
}