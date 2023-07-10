import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/widgets/day_period_input_padding.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class DayPeriodControl extends StatelessWidget {
  /// Creates a am/pm fragment.
  const DayPeriodControl({
    required this.selectedTime,
    required this.onChanged,
    required this.orientation,
    super.key,
  });

  /// The currently selected time.
  final TimeOfDayWithSecond? selectedTime;

  /// The orientation of the time picker, used to determine the layout.
  final Orientation orientation;

  /// Called when the user picks a new time.
  final ValueChanged<TimeOfDayWithSecond> onChanged;

  void _togglePeriod() {
    final newHour =
        (selectedTime!.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final newTime = selectedTime!.replacing(hour: newHour);
    onChanged(newTime);
  }

  void _setAm(BuildContext context) {
    if (selectedTime!.period == DayPeriod.am) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        TimePickerConstants.announceToAccessibility(
          context,
          MaterialLocalizations.of(context).anteMeridiemAbbreviation,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod();
  }

  void _setPm(BuildContext context) {
    if (selectedTime!.period == DayPeriod.pm) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        TimePickerConstants.announceToAccessibility(
          context,
          MaterialLocalizations.of(context).postMeridiemAbbreviation,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod();
  }

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final timePickerTheme = TimePickerTheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final textColor = timePickerTheme.dayPeriodTextColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.60);
        });
    final backgroundColor = timePickerTheme.dayPeriodColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          // The unselected day period should match the overall picker dialog
          // color. Making it transparent enables that without being redundant
          // and allows the optional elevation overlay for dark mode to be
          // visible.
          return states.contains(MaterialState.selected)
              ? colorScheme.primary.withOpacity(isDark ? 0.24 : 0.12)
              : Colors.transparent;
        });
    final amSelected = selectedTime!.period == DayPeriod.am;
    final amStates = amSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};
    final pmSelected = !amSelected;
    final pmStates = pmSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};
    final textStyle = timePickerTheme.dayPeriodTextStyle ??
        Theme.of(context).textTheme.titleMedium!;
    final amStyle = textStyle.copyWith(
      color: MaterialStateProperty.resolveAs(textColor, amStates),
    );
    final pmStyle = textStyle.copyWith(
      color: MaterialStateProperty.resolveAs(textColor, pmStates),
    );
    var shape = timePickerTheme.dayPeriodShape ??
        const RoundedRectangleBorder(
          borderRadius: TimePickerConstants.kDefaultBorderRadius,
        );
    final borderSide = timePickerTheme.dayPeriodBorderSide ??
        BorderSide(
          color: Color.alphaBlend(
            colorScheme.onBackground.withOpacity(0.38),
            colorScheme.surface,
          ),
        );
    // Apply the custom borderSide.
    shape = shape.copyWith(
      side: borderSide,
    );

    final double buttonTextScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 2);

    final hours = List.generate(
      12,
      (index) => TimeOfDayWithSecond(
        hour: index,
        minute: 0,
        second: 0,
      ),
    );
    final hasAMHours = hours.where((h) => _isSelectableTime(h)).isNotEmpty;

    final hasPMHours = hours
        .where((h) => _isSelectableTime(h.replacing(hour: h.hour + 12)))
        .isNotEmpty;

    final Widget amButton = Opacity(
      opacity: !hasAMHours ? 0.1 : 1,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, amStates),
        child: InkWell(
          onTap: () {
            if (hasAMHours) {
              Feedback.wrapForTap(() => _setAm(context), context)!.call();
            }
          },
          child: Semantics(
            selected: amSelected,
            child: Center(
              child: Text(
                materialLocalizations.anteMeridiemAbbreviation,
                style: amStyle,
                textScaleFactor: buttonTextScaleFactor,
              ),
            ),
          ),
        ),
      ),
    );

    final Widget pmButton = Opacity(
      opacity: !hasPMHours ? 0.1 : 1,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, pmStates),
        child: InkWell(
          onTap: () {
            if (hasPMHours) {
              Feedback.wrapForTap(() => _setPm(context), context)!.call();
            }
          },
          child: Semantics(
            selected: pmSelected,
            child: Center(
              child: Text(
                materialLocalizations.postMeridiemAbbreviation,
                style: pmStyle,
                textScaleFactor: buttonTextScaleFactor,
              ),
            ),
          ),
        ),
      ),
    );

    late Widget result;
    switch (orientation) {
      case Orientation.portrait:
        const width = 52.0;
        result = DayPeriodInputPadding(
          minSize: const Size(width, kMinInteractiveDimension * 2),
          orientation: orientation,
          child: SizedBox(
            width: width,
            height: TimePickerConstants.kTimePickerHeaderControlHeight,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: shape,
              child: Column(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: borderSide),
                    ),
                    height: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
        break;
      case Orientation.landscape:
        result = DayPeriodInputPadding(
          minSize: const Size(0, kMinInteractiveDimension),
          orientation: orientation,
          child: SizedBox(
            height: 40,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: shape,
              child: Row(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(left: borderSide),
                    ),
                    width: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
        break;
    }
    return result;
  }
}

late bool Function(TimeOfDayWithSecond? time) _isSelectableTime;
late dynamic Function() _notifyFailValidation;