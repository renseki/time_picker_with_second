import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/widgets/render_input_padding.dart';

/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
class DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  /// Creates a widget that insets its child.
  const DayPeriodInputPadding({
    super.key,
    super.child,
    this.minSize,
    this.orientation,
  });

  final Size? minSize;
  final Orientation? orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderInputPadding(minSize, orientation);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderInputPadding renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}
