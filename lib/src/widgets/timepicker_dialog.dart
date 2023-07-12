import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/enums/time_picker_unit_enum.dart';
import 'package:time_picker_with_second/src/widgets/controller_widget/hours_format_control.dart';
import 'package:time_picker_with_second/src/widgets/dial.dart';
import 'package:time_picker_with_second/src/widgets/timepicker_header.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// A material design time picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [TimeOfDay] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class TimePickerWithSecondsDialog extends StatefulWidget {
  /// Creates a material time picker.
  ///
  /// [initialTime] must not be null.
  TimePickerWithSecondsDialog({
    required this.initialTime,
    required this.cancelText,
    required this.confirmText,
    required this.helpText,
    super.key,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.selectableTimePredicate,
    this.onFailValidation,
  }) {
    assert(
      selectableTimePredicate == null || selectableTimePredicate!(initialTime),
      'Provided initialTime $initialTime must satisfy'
      ' provided selectableTimePredicate.',
    );
  }

  /// onFailValidation is called when the user clicks the confirm button and the
  final dynamic Function(BuildContext)? onFailValidation;

  /// The time initially selected when the dialog is shown.
  final TimeOfDayWithSecond initialTime;

  /// The entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode initialEntryMode;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own help text to the header of the time picker.
  final String? helpText;

  /// Function to provide full control over which [Time] can be selected.
  final SelectableTimePredicate? selectableTimePredicate;

  @override
  TimePickerWithSecondsDialogState createState() =>
      TimePickerWithSecondsDialogState();
}

/// State for a [TimePickerWithSecondsDialog].
class TimePickerWithSecondsDialogState
    extends State<TimePickerWithSecondsDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectableTimePredicate = widget.selectableTimePredicate;
    _entryMode = widget.initialEntryMode;
//     _autoValidate = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    _announceInitialTimeOnce();
    _announceModeOnce();
  }

  TimePickerEntryMode? _entryMode;
  TimePickerUnit _selectedUnit = TimePickerUnit.hour;
  TimePickerUnit? _lastUnitAnnounced;

//   bool _autoValidate;

  /// The currently selected time.
  TimeOfDayWithSecond? get selectedTime => _selectedTime;
  TimeOfDayWithSecond? _selectedTime;

  SelectableTimePredicate? _selectableTimePredicate;

  Timer? _vibrateTimer;

  bool _is24HourFormat = false;

  /// Device locale when the dialog was created.
  late MaterialLocalizations localizations;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _vibrateTimer?.cancel();
        _vibrateTimer = Timer(TimePickerConstants.kVibrateCommitDelay, () {
          HapticFeedback.vibrate();
          _vibrateTimer = null;
        });
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleUnitChanged(TimePickerUnit unit) {
    _vibrate();
    setState(() {
      _selectedUnit = unit;
      _announceModeOnce();
    });
  }

//   void _handleEntryModeToggle() {
//     setState(() {
//       switch (_entryMode) {
//         case TimePickerEntryMode.dial:
//           _autoValidate = false;
//           _entryMode = TimePickerEntryMode.input;
//           break;
//         case TimePickerEntryMode.input:
//           _formKey.currentState.save();
//           _entryMode = TimePickerEntryMode.dial;
//           break;
//       }
//     });
//   }

  void _announceModeOnce() {
    if (_lastUnitAnnounced == _selectedUnit) {
      // Already announced it.
      return;
    }

    switch (_selectedUnit) {
      case TimePickerUnit.hour:
        TimePickerConstants.announceToAccessibility(
          context,
          localizations.timePickerHourModeAnnouncement,
        );
        break;
      case TimePickerUnit.seconds:
        TimePickerConstants.announceToAccessibility(
          context,
          localizations.timePickerMinuteModeAnnouncement,
        );
        break;
      case TimePickerUnit.minute:
        TimePickerConstants.announceToAccessibility(
          context,
          localizations.timePickerMinuteModeAnnouncement,
        );
        break;
    }
    _lastUnitAnnounced = _selectedUnit;
  }

  bool _announcedInitialTime = false;

  void _announceInitialTimeOnce() {
    if (_announcedInitialTime) return;

    final media = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    TimePickerConstants.announceToAccessibility(
      context,
      localizations.formatTimeOfDay(
        widget.initialTime,
        alwaysUse24HourFormat: media.alwaysUse24HourFormat,
      ),
    );
    _announcedInitialTime = true;
  }

  void _handleTimeChanged(TimeOfDayWithSecond? value) {
    _vibrate();
    setState(() {
      _selectedTime = value;
    });
  }

  void _handleHourSelected() {
    setState(() {
      _selectedUnit = TimePickerUnit.minute;
    });
  }

  void _handleMinuteSelected() {
    setState(() {
      _selectedUnit = TimePickerUnit.seconds;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    if (!TimePickerConstants.isSelectableTime(
      time: selectedTime,
      selectableTimePredicate: _selectableTimePredicate,
    )) {
      TimePickerConstants.notifyFailValidation(
        context: context,
        onFailValidation: widget.onFailValidation,
      );
      return;
    }

    if (_entryMode == TimePickerEntryMode.input) {
      final form = _formKey.currentState!;
      if (!form.validate()) {
//         setState(() {
//           _autoValidate = true;
//         });
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedTime);
  }

  Size _dialogSize(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);
    // Constrain the textScaleFactor to prevent layout issues. Since only some
    // parts of the time picker scale up with textScaleFactor, we cap the factor
    // to 1.1 as that provides enough space to reasonably fit all the content.
    final double textScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 1.1);

    late double timePickerWidth;
    late double timePickerHeight;
    switch (_entryMode) {
      case null:
        break;
      case TimePickerEntryMode.dial:
        switch (orientation) {
          case Orientation.portrait:
            timePickerWidth = TimePickerConstants.kTimePickerWidthPortrait;
            timePickerHeight =
                theme.materialTapTargetSize == MaterialTapTargetSize.padded
                    ? TimePickerConstants.kTimePickerHeightPortrait
                    : TimePickerConstants.kTimePickerHeightPortraitCollapsed;
            break;
          case Orientation.landscape:
            timePickerWidth =
                TimePickerConstants.kTimePickerWidthLandscape * textScaleFactor;
            timePickerHeight =
                theme.materialTapTargetSize == MaterialTapTargetSize.padded
                    ? TimePickerConstants.kTimePickerHeightLandscape
                    : TimePickerConstants.kTimePickerHeightLandscapeCollapsed;
            break;
        }
        break;
      case TimePickerEntryMode.input:
        timePickerWidth = TimePickerConstants.kTimePickerWidthPortrait;
        timePickerHeight = TimePickerConstants.kTimePickerHeightInput;
        break;
      case TimePickerEntryMode.dialOnly:
        break;
      case TimePickerEntryMode.inputOnly:
        break;
    }
    return Size(timePickerWidth, timePickerHeight * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context), 'No MediaQuery widget found.');

    final media = MediaQuery.of(context);
    final use24HourDials = _is24HourFormat;
    final theme = Theme.of(context);
    final shape =
        TimePickerTheme.of(context).shape ?? TimePickerConstants.kDefaultShape;

    final orientation = media.orientation;

    final Widget actions = Row(
      children: <Widget>[
        const SizedBox(width: 10),
        HourFormatControl(
          is24HourFormat: _is24HourFormat,
          onToggle: () {
            setState(() {
              _is24HourFormat = !_is24HourFormat;
            });
          },
        ),
        const Spacer(),
        Expanded(
          child: ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: <Widget>[
              TextButton(
                onPressed: _handleCancel,
                child: Text(
                  widget.cancelText ?? localizations.cancelButtonLabel,
                ),
              ),
              TextButton(
                onPressed: _handleOk,
                child: Text(
                  widget.confirmText ?? localizations.okButtonLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget? picker;
    switch (_entryMode) {
      case null:
        break;
      case TimePickerEntryMode.dial:
        final Widget dial = Padding(
          padding: orientation == Orientation.portrait
              ? const EdgeInsets.symmetric(horizontal: 36, vertical: 24)
              : const EdgeInsets.all(24),
          child: ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 1,
              child: Dial(
                unit: _selectedUnit,
                use24HourDials: _is24HourFormat,
                selectedTime: _selectedTime!,
                onChanged: _handleTimeChanged,
                onHourSelected: _handleHourSelected,
                onMinuteSelected: _handleMinuteSelected,
                selectableTimePredicate: _selectableTimePredicate,
              ),
            ),
          ),
        );

        final Widget header = TimePickerHeader(
          selectedTime: _selectedTime!,
          unit: _selectedUnit,
          orientation: orientation,
          onUnitChanged: _handleUnitChanged,
          onChanged: _handleTimeChanged,
          use24HourDials: use24HourDials,
          helpText: widget.helpText,
          selectableTimePredicate: _selectableTimePredicate,
        );

        switch (orientation) {
          case Orientation.portrait:
            picker = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                header,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Dial grows and shrinks with the available space.
                      Expanded(child: dial),
                      actions,
                    ],
                  ),
                ),
              ],
            );
            break;
          case Orientation.landscape:
            picker = Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      header,
                      Expanded(child: dial),
                    ],
                  ),
                ),
                actions,
              ],
            );
            break;
        }
        break;
      case TimePickerEntryMode.input:
        // TODO(Zagustan): Handle onInput mode
        break;
      case TimePickerEntryMode.dialOnly:
        // TODO(Zagustan): Handle this case.
        break;
      case TimePickerEntryMode.inputOnly:
        // TODO(Zagustan): Handle this case.
        break;
    }

    final dialogSize = _dialogSize(context);
    return Builder(
      builder: (context) {

        final backgroundColor = TimePickerTheme.of(context).backgroundColor ??
            theme.colorScheme.surface;

        final verticalPadding =
            _entryMode == TimePickerEntryMode.input ? 0.0 : 24.0;

        return Dialog(
          shape: shape,
          backgroundColor: backgroundColor,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: verticalPadding,
          ),
          child: AnimatedContainer(
            width: dialogSize.width,
            height: dialogSize.height,
            duration: TimePickerConstants.kDialogSizeAnimationDuration,
            curve: Curves.easeIn,
            child: picker,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }
}
