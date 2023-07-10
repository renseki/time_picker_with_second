import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// Provides properties for rendering time picker header fragments.
@immutable
class TimePickerFragmentContext {
  /// Creates a context for rendering time picker header fragments.
  const TimePickerFragmentContext({
    required this.selectedTime,
    required this.mode,
    required this.onTimeChange,
    required this.onModeChange,
    required this.use24HourDials,
  });

  /// The currently selected time.
  final TimeOfDayWithSecond selectedTime;
  /// The current [TimePickerUnit] of the time picker.
  final TimePickerUnit mode;
  /// Called when the selected time should be changed.
  final ValueChanged<TimeOfDayWithSecond> onTimeChange;
  /// Called when the current [TimePickerUnit] should be changed.
  final ValueChanged<TimePickerUnit> onModeChange;
  /// Whether 24 hour dials are used.
  final bool use24HourDials;
}
