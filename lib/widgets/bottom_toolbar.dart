import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomToolbar extends StatelessWidget {
  final Color selectedColor;
  final bool isEraserMode;
  final double strokeWidth;
  final bool isPlaying;
  final bool showOnionSkin;
  final VoidCallback onToggleEraser;
  final VoidCallback onColorTap;
  final VoidCallback onBrushSizeTap;
  final VoidCallback onSave;
  final VoidCallback onPlay;
  final VoidCallback onClear;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onToggleOnionSkin;
  final ValueChanged<String> onFpsChanged;
  final String fpsValue;

  const BottomToolbar({
    super.key,
    required this.selectedColor,
    required this.isEraserMode,
    required this.strokeWidth,
    required this.isPlaying,
    required this.showOnionSkin,
    required this.onToggleEraser,
    required this.onColorTap,
    required this.onBrushSizeTap,
    required this.onSave,
    required this.onPlay,
    required this.onClear,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleOnionSkin,
    required this.onFpsChanged,
    required this.fpsValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row (
              spacing: 8,
              children: [
                // Color Picker
                _ToolbarButton(
                  tooltip: 'Color Picker',
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                  ),
                  onTap: onColorTap,
                ),

                // Brush Size
                _ToolbarButton(
                  tooltip: 'Brush Size (${strokeWidth.round()})',
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        strokeWidth.round().toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  onTap: onBrushSizeTap,
                ),

                // Eraser/Brush Toggle
                _ToolbarButton(
                  tooltip: isEraserMode ? 'Switch to Brush' : 'Switch to Eraser',
                  child: Icon(
                    isEraserMode ? Icons.brush : FontAwesomeIcons.eraser,
                    size: 20,
                  ),
                  onTap: onToggleEraser,
                ),

                // Undo/Redo Buttons
                _ToolbarButton(
                  tooltip: 'Undo',
                  child: const Icon(Icons.undo, size: 20),
                  onTap: onUndo,
                ),
                _ToolbarButton(
                  tooltip: 'Redo',
                  child: const Icon(Icons.redo, size: 20),
                  onTap: onRedo,
                ),

                // Clear Button
                _ToolbarButton(
                  tooltip: 'Clear Canvas',
                  child: const Icon(Icons.clear, size: 20),
                  onTap: onClear,
                ),

                // Onion Skin Toggle
                _ToolbarButton(
                  tooltip: showOnionSkin ? 'Hide Onion Skin' : 'Show Onion Skin',
                  child: Icon(
                    showOnionSkin ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  onTap: onToggleOnionSkin,
                ),
              ],
            ),

            Row (
              spacing: 8,
              children: [
                // FPS Control
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: TextEditingController(text: fpsValue),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "FPS",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: onFpsChanged,
                  ),
                ),

                // Save Button
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onSave,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text("Save Frame"),
                ),

                // Play/Pause Button
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isPlaying
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: isPlaying
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onPlay,
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 18),
                  label: Text(isPlaying ? "Stop" : "Play"),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String tooltip;
  final Widget child;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.tooltip,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          child: Center(child: child),
        ),
      ),
    );
  }
}