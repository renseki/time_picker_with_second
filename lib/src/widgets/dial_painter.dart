import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/widgets/tappable_label.dart';

///
class DialPainter extends CustomPainter {
  ///
  DialPainter({
    required this.primaryLabels,
    required this.secondaryLabels,
    required this.backgroundColor,
    required this.accentColor,
    required this.dotColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
  }) : super(repaint: PaintingBinding.instance.systemFonts);

  /// The labels to display in the primary positions (e.g., 1, 2, 3, 4).
  final List<TappableLabel>? primaryLabels;

  /// The labels to display in the secondary positions (e.g., 15, 30, 45, 60).
  final List<TappableLabel>? secondaryLabels;

  /// The color to use for the background of the clock face.
  final Color backgroundColor;

  /// The color to use for the selected label.
  final Color accentColor;

  /// The color to use for the dots between the labels.
  final Color dotColor;

  /// The angle, in radians, of the selected value.
  final double theta;

  /// The text direction.
  final TextDirection textDirection;

  /// The currently selected value.
  final int? selectedValue;

  static const double _labelPadding = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor);

    final labelRadius = radius - _labelPadding;

    Offset getOffsetForTheta(double theta) {
      final dx = labelRadius * math.cos(theta);
      final dy = -labelRadius * math.sin(theta);
      final result = center + Offset(dx, dy);
      return result;
    }

    void paintLabels(List<TappableLabel>? labels) {
      if (labels == null) return;
      final labelThetaIncrement = -TimePickerConstants.kTwoPi / labels.length;
      var labelTheta = math.pi / 2.0;

      for (final label in labels) {
        final labelPainter = label.painter;
        final dx = -labelPainter.width / 2.0;
        final dy = -labelPainter.height / 2.0;

        final labelOffset = Offset(dx, dy);

        labelPainter.paint(canvas, getOffsetForTheta(labelTheta) + labelOffset);

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(primaryLabels);

    final selectorPaint = Paint()..color = accentColor;
    final focusedPoint = getOffsetForTheta(theta);
    const focusedRadius = _labelPadding - 4.0;
    canvas
      ..drawCircle(centerPoint, 4, selectorPaint)
      ..drawCircle(focusedPoint, focusedRadius, selectorPaint);
    selectorPaint.strokeWidth = 2.0;
    canvas.drawLine(centerPoint, focusedPoint, selectorPaint);

    // Add a dot inside the selector but only when it isn't over the labels.
    // This checks that the selector's theta is between two labels. A remainder
    // between 0.1 and 0.45 indicates that the selector is roughly not above any
    // labels. The values were derived by manually testing the dial.
    final labelThetaIncrement =
        -TimePickerConstants.kTwoPi / primaryLabels!.length;
    if (theta % labelThetaIncrement > 0.1 &&
        theta % labelThetaIncrement < 0.45) {
      canvas.drawCircle(focusedPoint, 2, selectorPaint..color = dotColor);
    }

    final focusedRect = Rect.fromCircle(
      center: focusedPoint,
      radius: focusedRadius,
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(focusedRect));
    paintLabels(secondaryLabels);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) {
    return oldDelegate.primaryLabels != primaryLabels ||
        oldDelegate.secondaryLabels != secondaryLabels ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.theta != theta;
  }
}
