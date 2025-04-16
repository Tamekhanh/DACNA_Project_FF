import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void showColorPickerDialog(
    BuildContext context, {
      required Color initialColor,
      required ValueChanged<Color> onColorPicked,
    }) {
  Color tempColor = initialColor;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choose color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: tempColor,
          onColorChanged: (color) => tempColor = color,
          enableAlpha: false,
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onColorPicked(tempColor);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
