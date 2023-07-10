import 'package:flutter/material.dart';

/// A fragment showing a string value.
class StringFragment extends StatelessWidget {
  /// Creates a fragment showing a string value.
  const StringFragment({
    required this.timeOfDayFormat,
    super.key,
  });

  /// The format of the time of day.
  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    var result = '';
    switch (timeOfDayFormat) {
      case TimeOfDayFormat.h_colon_mm_space_a:
      case TimeOfDayFormat.a_space_h_colon_mm:
      case TimeOfDayFormat.H_colon_mm:
      case TimeOfDayFormat.HH_colon_mm:
        result = ':';
        break;
      case TimeOfDayFormat.HH_dot_mm:
        result = '.';
        break;
      case TimeOfDayFormat.frenchCanadian:
        result = 'h';
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timePickerTheme = TimePickerTheme.of(context);
    final hourMinuteStyle =
        timePickerTheme.hourMinuteTextStyle ?? theme.textTheme.displaySmall!;
    final textColor =
        timePickerTheme.hourMinuteTextColor ?? theme.colorScheme.onSurface;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Text(
            _stringFragmentValue(timeOfDayFormat),
            style: hourMinuteStyle.apply(
              color: MaterialStateProperty.resolveAs(
                textColor,
                <MaterialState>{},
              ),
            ),
            textScaleFactor: 1,
          ),
        ),
      ),
    );
  }
}
