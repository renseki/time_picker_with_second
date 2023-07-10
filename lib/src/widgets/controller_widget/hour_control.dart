import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/main_control.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_fragment.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [TimePickerUnit.hour].
class HourControl extends StatelessWidget {
  /// Creates an hour fragment.
  const HourControl({
    required this.fragmentContext,
    super.key,
  });

  /// The context for the time picker header fragment.
  final TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context), 'No MediaQuery widget found.');
    final alwaysUse24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final localizations = MaterialLocalizations.of(context);
    final formattedHour = localizations.formatHour(
      fragmentContext.selectedTime,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    TimeOfDayWithSecond hoursFromSelected(int hoursToAdd) {
      if (fragmentContext.use24HourDials) {
        final selectedHour = fragmentContext.selectedTime.hour;
        return fragmentContext.selectedTime.replacing(
          hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
        );
      } else {
        // Cycle 1 through 12 without changing day period.
        final periodOffset = fragmentContext.selectedTime.periodOffset;
        final hours = fragmentContext.selectedTime.hourOfPeriod;
        return fragmentContext.selectedTime.replacing(
          hour: periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
        );
      }
    }

    final nextHour = hoursFromSelected(1);

    final formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    final previousHour = hoursFromSelected(-1);

    final formattedPreviousHour = localizations.formatHour(
      previousHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    return Semantics(
      hint: localizations.timePickerHourModeAnnouncement,
      value: formattedHour,
      excludeSemantics: true,
      increasedValue: formattedNextHour,
      onIncrease: () {
        fragmentContext.onTimeChange(nextHour);
      },
      decreasedValue: formattedPreviousHour,
      onDecrease: () {
        fragmentContext.onTimeChange(previousHour);
      },
      child: HourMinuteSecondsControl(
        isSelected: fragmentContext.mode == TimePickerUnit.hour,
        text: formattedHour,
        onTap: Feedback.wrapForTap(
          () => fragmentContext.onModeChange(TimePickerUnit.hour),
          context,
        )!,
      ),
    );
  }
}
