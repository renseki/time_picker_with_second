import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// Signature for predicating times for enabled time selections.
typedef SelectableTimePredicate = bool Function(TimeOfDayWithSecond time);

/// Constants that are used in multiple time picker classes.
class TimePickerConstants {
  /// The default duration of the transition used when switching between
  /// AM/PM and hour/minute/second modes.
  static const Duration kDialogSizeAnimationDuration =
      Duration(milliseconds: 200);

  /// The default duration of the transition used when expanding
  static const Duration kExpand = Duration(milliseconds: 200);

  /// The default duration of the transition used when collapsing
  static const Duration kDialAnimateDuration = Duration(milliseconds: 200);

  /// The default duration of the transition used for vibration before
  /// committing a selection.
  static const Duration kVibrateCommitDelay = Duration(milliseconds: 100);

  /// The number of degrees to rotate the dial for each hour.
  static const double kTwoPi = 2 * math.pi;

  /// The width of the time picker's header.
  static const double kTimePickerHeaderLandscapeWidth = 264;

  /// The height of the time picker's header.
  static const double kTimePickerHeaderControlHeight = 80;

  /// The width of the time picker's dial on portrait mode.
  static const double kTimePickerWidthPortrait = 328;

  /// The width of the time picker's dial on landscape mode.
  static const double kTimePickerWidthLandscape = 528;

  /// The height of the time picker's input
  static const double kTimePickerHeightInput = 226;

  /// The height of the time picker's dial on portrait mode.
  static const double kTimePickerHeightPortrait = 496;

  /// The height of the time picker's dial on landscape mode.
  static const double kTimePickerHeightLandscape = 316;

  /// The height of the time picker's dial on portrait mode when collapsed.
  static const double kTimePickerHeightPortraitCollapsed = 484;

  /// The height of the time picker's dial on landscape mode when collapsed.
  static const double kTimePickerHeightLandscapeCollapsed = 304;

  /// The default border radius
  static const BorderRadius kDefaultBorderRadius =
      BorderRadius.all(Radius.circular(4));

  /// The default shape of the time picker's dial.
  static const ShapeBorder kDefaultShape =
      RoundedRectangleBorder(borderRadius: kDefaultBorderRadius);

  /// Announcing the time picker to accessibility services.
  static void announceToAccessibility(
    BuildContext context,
    String message,
  ) {
    SemanticsService.announce(
      message,
      Directionality.of(context),
    );
  }

  /// Notifying the time picker when validation fails.
  static void notifyFailValidation({
    required BuildContext context,
    dynamic Function(BuildContext)? onFailValidation,
  }) {
    onFailValidation?.call(context);
  }
}
