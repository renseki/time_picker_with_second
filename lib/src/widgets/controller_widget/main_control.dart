import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';

/// A fragment showing the hour, minute, or second value.
class HourMinuteSecondsControl extends StatelessWidget {
  /// Creates a fragment showing a string value.
  const HourMinuteSecondsControl({
    required this.text,
    required this.onTap,
    required this.isSelected,
    super.key,
  });

  /// The text to display.
  final String text;

  /// The callback when the fragment is tapped.
  final GestureTapCallback onTap;

  /// Whether the fragment is selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final timePickerTheme = TimePickerTheme.of(context);

    final isDark = themeData.colorScheme.brightness == Brightness.dark;

    final textColor = timePickerTheme.hourMinuteTextColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? themeData.colorScheme.primary
              : themeData.colorScheme.onSurface;
        });

    final backgroundColor = timePickerTheme.hourMinuteColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? themeData.colorScheme.primary.withOpacity(isDark ? 0.24 : 0.12)
              : themeData.colorScheme.onSurface.withOpacity(0.12);
        });

    final style = timePickerTheme.hourMinuteTextStyle ??
        themeData.textTheme.displaySmall!;

    final shape =
        timePickerTheme.hourMinuteShape ?? TimePickerConstants.kDefaultShape;

    final states = isSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};

    return SizedBox(
      height: TimePickerConstants.kTimePickerHeaderControlHeight,
      child: Material(
        color: MaterialStateProperty.resolveAs(
          backgroundColor,
          states,
        ),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: style.copyWith(
                color: MaterialStateProperty.resolveAs(
                  textColor,
                  states,
                ),
              ),
              textScaleFactor: 1,
            ),
          ),
        ),
      ),
    );
  }
}
