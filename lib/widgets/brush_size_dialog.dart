import 'package:flutter/material.dart';

void showBrushSizeDialog(
    BuildContext context, {
      required double initialSize,
      required ValueChanged<double> onSizeChanged,
    }) {
  double tempSize = initialSize;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Brush size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: tempSize,
              min: 1,
              max: 50,
              divisions: 49,
              label: tempSize.round().toString(),
              onChanged: (value) => setStateDialog(() => tempSize = value),
            ),
            Text('${tempSize.round()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onSizeChanged(tempSize);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}
