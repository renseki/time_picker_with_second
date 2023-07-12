import 'package:flutter/material.dart';

/// A label that can be tapped.
class TappableLabel {
  /// Creates a label that can be tapped.
  TappableLabel({
    required this.value,
    required this.painter,
    required this.onTap,
  });

  /// The value this label is displaying.
  final int value;

  /// Paints the text of the label.
  final TextPainter painter;

  /// Called when a tap gesture is detected on the label.
  final VoidCallback? onTap;
}
