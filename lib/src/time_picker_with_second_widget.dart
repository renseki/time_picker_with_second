// ignore_for_file: comment_references, prefer_asserts_in_initializer_lists
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/utils/num_extension.dart';
import 'package:time_picker_with_second/src/time_of_day_with_second.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_dialog.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_fragment.dart';

/// Shows a dialog containing a material design time picker.
///
/// The returned Future resolves to the time selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// {@tool snippet}
/// Show a dialog with [initialTime] equal to the current time.
///
/// ```dart
/// Future<TimeOfDay> selectedTime = showTimePicker(
///   initialTime: TimeOfDay.now(),
///   context: context,
/// );
/// ```
/// {@end-tool}
///
/// The [context], [useRootNavigator]
/// and [routeSettings] arguments are passed to
/// [showDialog], the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Localizations.override],
/// [Directionality], or [MediaQuery].
///
/// The [entryMode] parameter can be used to
/// determine the initial time entry selection of the picker (either a clock
/// dial or text input).
///
/// Optional strings for the [helpText], [cancelText], and [confirmText] can be
/// provided to override the default values.
///
/// {@tool snippet}
/// Show a dialog with the text direction overridden to be [TextDirection.rtl].
///
/// ```dart
/// Future<TimeOfDay> selectedTimeRTL = showTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
///   builder: (BuildContext context, Widget child) {
///     return Directionality(
///       textDirection: TextDirection.rtl,
///       child: child,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// Show a dialog with time unconditionally displayed in 24 hour format.
///
/// ```dart
/// Future<TimeOfDay> selectedTime24Hour = showTimePicker(
///   context: context,
///   initialTime: TimeOfDay(hour: 10, minute: 47),
///   builder: (BuildContext context, Widget child) {
///     return MediaQuery(
///       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
///       child: child,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
Future<TimeOfDayWithSecond?> showTimePickerWithSecond({
  required BuildContext context,
  required TimeOfDayWithSecond initialTime,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? cancelText,
  String? confirmText,
  String? helpText,
  RouteSettings? routeSettings,
  bool Function(TimeOfDayWithSecond?)? selectableTimePredicate,
  dynamic Function(BuildContext)? onFailValidation,
}) async {
  assert(
    debugCheckHasMaterialLocalizations(context),
    'A context with MaterialLocalizations is required.',
  );
  assert(
    onFailValidation != null || selectableTimePredicate == null,
    "'onFailValidation' can't be null"
    " if 'selectableTimePredicate' has been set",
  );

  _isSelectableTime = (time) => selectableTimePredicate?.call(time) ?? true;

  final Widget dialog = TimePickerWithSecondsDialog(
    initialTime: initialTime,
    initialEntryMode: initialEntryMode,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
    selectableTimePredicate: selectableTimePredicate,
  );

  return showDialog<TimeOfDayWithSecond>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      _notifyFailValidation = () => onFailValidation?.call(context);
      return builder == null ? dialog : builder(context, dialog);
    },
    routeSettings: routeSettings,
  );
}

late bool Function(TimeOfDayWithSecond? time) _isSelectableTime;
late dynamic Function() _notifyFailValidation;
