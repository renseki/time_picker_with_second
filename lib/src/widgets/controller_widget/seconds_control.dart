import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/main_control.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_fragment.dart';

/// Display The Seconds Picker
class SecondsControl extends StatelessWidget {
  /// Creates a seconds fragment.
  const SecondsControl({
    required this.fragmentContext,
    super.key,
  });

  /// The context for the time picker header fragment.
  final TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    final formattedSeconds = fragmentContext.selectedTime.formatSeconds;

    final nextSecond = fragmentContext.selectedTime.replacing(
      seconds:
          (fragmentContext.selectedTime.second + 1) % TimeOfDay.minutesPerHour,
    );

    final formattedNextSecond = nextSecond.formatSeconds;

    final previousSecond = fragmentContext.selectedTime.replacing(
      seconds:
          (fragmentContext.selectedTime.second - 1) % TimeOfDay.minutesPerHour,
    );

    final formattedPreviousSecond = previousSecond.formatSeconds;

    return Semantics(
      excludeSemantics: true,
      hint: localizations.timePickerMinuteModeAnnouncement,
      value: formattedSeconds,
      increasedValue: formattedNextSecond,
      onIncrease: () {
        fragmentContext.onTimeChange(nextSecond);
      },
      decreasedValue: formattedPreviousSecond,
      onDecrease: () {
        fragmentContext.onTimeChange(previousSecond);
      },
      child: HourMinuteSecondsControl(
        isSelected: fragmentContext.mode == TimePickerUnit.seconds,
        text: formattedSeconds,
        onTap: Feedback.wrapForTap(
          () => fragmentContext.onModeChange(TimePickerUnit.seconds),
          context,
        )!,
      ),
    );
  }
}
