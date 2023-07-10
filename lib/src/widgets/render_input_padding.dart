import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///
class RenderInputPadding extends RenderShiftedBox {
  ///
  RenderInputPadding(this._minSize, this.orientation, [RenderBox? child])
      : super(child);

  /// The current orientation of the app.
  final Orientation? orientation;

  /// The minimum size of the child.
  Size? get minSize => _minSize;
  Size? _minSize;

  set minSize(Size? value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize!.width);
    }
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(
        child!.getMinIntrinsicHeight(width),
        minSize!.height,
      );
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize!.width);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize!.height);
    }
    return 0;
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      final double width = math.max(child!.size.width, minSize!.width);
      final double height = math.max(child!.size.height, minSize!.height);
      size = constraints.constrain(Size(width, height));

      // set the child's position to the center of the available space
      (child!.parentData! as BoxParentData).offset =
          Alignment.center.alongOffset(size - child!.size as Offset);
    } else {
      size = Size.zero;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (position.dx < 0.0 ||
        position.dx > math.max(child!.size.width, minSize!.width) ||
        position.dy < 0.0 ||
        position.dy > math.max(child!.size.height, minSize!.height)) {
      return false;
    }

    var newPosition = child!.size.center(Offset.zero);
    switch (orientation) {
      case null:
        break;
      case Orientation.portrait:
        if (position.dy > newPosition.dy) {
          newPosition += const Offset(0, 1);
        } else {
          newPosition += const Offset(0, -1);
        }
        break;
      case Orientation.landscape:
        if (position.dx > newPosition.dx) {
          newPosition += const Offset(1, 0);
        } else {
          newPosition += const Offset(-1, 0);
        }
        break;
    }

    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(newPosition),
      position: newPosition,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == newPosition, 'Transformed position is the same');
        return child!.hitTest(result, position: newPosition);
      },
    );
  }
}
