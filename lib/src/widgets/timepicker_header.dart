import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/utils/num_extension.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/day_period_control.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/hour_control.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/minute_control.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/seconds_control.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/string_fragment.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_fragment.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// Header for the time picker that's shown above the AM/PM and hour/minute/second
class TimePickerHeader extends StatelessWidget {
  /// named constructor
  const TimePickerHeader({
    required this.selectedTime,
    required this.mode,
    required this.orientation,
    required this.onModeChanged,
    required this.onChanged,
    required this.use24HourDials,
    required this.helpText,
    super.key,
    this.selectableTimePredicate,
  });

  /// The currently selected time.
  final TimeOfDayWithSecond selectedTime;

  /// The current [TimePickerUnit] of the time picker.
  final TimePickerUnit mode;

  /// The orientation of the time picker.
  final Orientation orientation;

  /// Called when the current [TimePickerUnit] should be changed.
  final ValueChanged<TimePickerUnit> onModeChanged;

  /// Called when the selected time should be changed.
  final ValueChanged<TimeOfDayWithSecond> onChanged;

  /// Whether 24 hour dials are used.
  final bool use24HourDials;

  /// The help text to display.
  final String? helpText;

  /// The predicate to use for determining which times are selectable.
  final SelectableTimePredicate? selectableTimePredicate;

  void _handleChangeMode(TimePickerUnit value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context), 'No MediaQuery widget found.');

    final themeData = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    final mediaQuery24HourFormat = mediaQuery.alwaysUse24HourFormat;

    final timeOfDayFormat = localizations.timeOfDayFormat(
      alwaysUse24HourFormat: mediaQuery24HourFormat,
    );

    final fragmentContext = TimePickerFragmentContext(
      selectedTime: selectedTime,
      mode: mode,
      onTimeChange: onChanged,
      onModeChange: _handleChangeMode,
      use24HourDials: use24HourDials,
    );

    EdgeInsets? padding;
    double? width;
    Widget? controls;

    final formatIsNotAmPm =
        timeOfDayFormat != TimeOfDayFormat.a_space_h_colon_mm;
    final formatIsAmPm = timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm;

    final not24HourDialNonMeridian = !use24HourDials && formatIsNotAmPm;
    final not24HourDialWithMeridian = !use24HourDials && formatIsAmPm;

    final dayPeriodControl = DayPeriodControl(
      selectedTime: selectedTime,
      orientation: orientation,
      onChanged: onChanged,
    );

    final hourControl = HourControl(fragmentContext: fragmentContext);
    final expandedHourControl = Expanded(child: hourControl);

    final minuteControl = MinuteControl(fragmentContext: fragmentContext);
    final secondsControl = SecondsControl(fragmentContext: fragmentContext);
    final expandedMinuteControl = Expanded(child: minuteControl);
    final expandedSecondsControl = Expanded(child: secondsControl);

    final stringFragment = StringFragment(timeOfDayFormat: timeOfDayFormat);

    switch (orientation) {
      case Orientation.portrait:
        // Keep width null because in portrait we don't cap the width.
        padding = const EdgeInsets.symmetric(horizontal: 24);
        controls = Column(
          children: <Widget>[
            const SizedBox(height: 16),
            SizedBox(
              height: kMinInteractiveDimension * 2,
              child: Row(
                children: <Widget>[
                  if (not24HourDialWithMeridian) ...[
                    dayPeriodControl,
                    12.widthBox,
                  ],
                  Expanded(
                    child: Row(
                      // Hour/minutes should not change positions in RTL locales.
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        expandedHourControl,
                        stringFragment,
                        expandedMinuteControl,
                        stringFragment,
                        expandedSecondsControl,
                      ],
                    ),
                  ),
                  if (not24HourDialNonMeridian) ...<Widget>[
                    12.widthBox,
                    dayPeriodControl,
                  ],
                ],
              ),
            ),
          ],
        );
        break;
      case Orientation.landscape:
        width = TimePickerConstants.kTimePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        controls = Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (not24HourDialWithMeridian) dayPeriodControl,
              SizedBox(
                height: kMinInteractiveDimension * 2,
                child: Row(
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    expandedHourControl,
                    stringFragment,
                    expandedMinuteControl,
                    stringFragment,
                    expandedSecondsControl,
                  ],
                ),
              ),
              if (not24HourDialNonMeridian) dayPeriodControl,
            ],
          ),
        );
        break;
    }

    return Container(
      width: width,
      padding: padding,
      child: Builder(
        builder: (context) {
          final helpTextContent = helpText ??
              MaterialLocalizations.of(context).timePickerDialHelpText;

          final helpTextStyle = TimePickerTheme.of(context).helpTextStyle ??
              themeData.textTheme.labelSmall;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              16.heightBox,
              Text(
                helpTextContent,
                style: helpTextStyle,
              ),
              controls!,
            ],
          );
        },
      ),
    );
  }
}
