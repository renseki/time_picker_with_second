import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/main_control.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_fragment.dart';

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [TimePickerUnit.minute].
class MinuteControl extends StatelessWidget {
  /// Creates a minute fragment.
  const MinuteControl({
    required this.fragmentContext,
  });

  /// The context for the time picker header fragment.
  final TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    final formattedMinute =
        localizations.formatMinute(fragmentContext.selectedTime);

    final nextMinute = fragmentContext.selectedTime.replacing(
      minute:
          (fragmentContext.selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );

    final formattedNextMinute = localizations.formatMinute(nextMinute);

    final previousMinute = fragmentContext.selectedTime.replacing(
      minute:
          (fragmentContext.selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );

    final formattedPreviousMinute = localizations.formatMinute(previousMinute);

    return Semantics(
      excludeSemantics: true,
      hint: localizations.timePickerMinuteModeAnnouncement,
      value: formattedMinute,
      increasedValue: formattedNextMinute,
      onIncrease: () {
        fragmentContext.onTimeChange(nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        fragmentContext.onTimeChange(previousMinute);
      },
      child: HourMinuteSecondsControl(
        isSelected: fragmentContext.mode == TimePickerUnit.minute,
        text: formattedMinute,
        onTap: Feedback.wrapForTap(
          () => fragmentContext.onModeChange(TimePickerUnit.minute),
          context,
        )!,
      ),
    );
  }
}
