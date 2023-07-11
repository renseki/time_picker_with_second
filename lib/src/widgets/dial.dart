import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:time_picker_with_second/src/constants/time_picker_constants.dart';
import 'package:time_picker_with_second/src/enums/time_picker_enum.dart';
import 'package:time_picker_with_second/src/widgets/dial_painter.dart';
import 'package:time_picker_with_second/src/widgets/tappable_label.dart';
import 'package:time_picker_with_second/time_picker_with_second.dart';

/// A dial that can be turned to set a time.
class Dial extends StatefulWidget {
  /// Creates a dial that can be turned to set a time.
  const Dial({
    required this.selectedTime,
    required this.mode,
    required this.use24HourDials,
    required this.onChanged,
    required this.onHourSelected,
    required this.onMinuteSelected,
    super.key,
    this.selectableTimePredicate,
  });

  /// The currently selected time.
  final TimeOfDayWithSecond selectedTime;

  /// The mode of the time picker.
  final TimePickerUnit mode;

  /// Whether 24 hour dials should be used.
  final bool use24HourDials;

  /// Called when the selected time changes.
  final ValueChanged<TimeOfDayWithSecond> onChanged;

  /// Called when the hour changes.
  final VoidCallback onHourSelected;

  /// Called when the minute changes.
  final VoidCallback onMinuteSelected;

  /// Optional predicate for determining which times are selectable.
  final SelectableTimePredicate? selectableTimePredicate;

  @override
  DialState createState() => DialState();
}

/// The state of a [Dial].
class DialState extends State<Dial> with SingleTickerProviderStateMixin {
  TimeOfDayWithSecond? _lastSelectableTime;

  bool get _isAM => widget.selectedTime.period == DayPeriod.am;

  @override
  void initState() {
    super.initState();
    _lastSelectableTime = widget.selectedTime;
    _thetaController = AnimationController(
      duration: TimePickerConstants.kDialAnimateDuration,
      vsync: this,
    );

    _thetaTween = Tween<double>(
      begin: _getThetaForTime(
        widget.selectedTime,
      ),
    );

    _theta = _thetaController!
        .drive(CurveTween(curve: Curves.easeIn))
        .drive(_thetaTween!)
      ..addListener(
        () => setState(() {
          /* _theta.value has changed */
        }),
      );
  }

  /// themeData
  late ThemeData themeData;

  /// device locale
  late MaterialLocalizations localizations;

  /// media
  late MediaQueryData media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context), 'No MediaQuery widget found.');
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void didUpdateWidget(Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isModeChanged = widget.mode != oldWidget.mode;
    final isSelectedTimeChanged = widget.selectedTime != oldWidget.selectedTime;
    if (isModeChanged || isSelectedTimeChanged) {
      if (!_dragging) _animateTo(_getThetaForTime(widget.selectedTime));
    }
  }

  @override
  void dispose() {
    _thetaController!.dispose();
    super.dispose();
  }

  late Tween<double>? _thetaTween;
  late Animation<double> _theta;
  late AnimationController? _thetaController;
  bool _dragging = false;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta = _nearest(
      targetTheta,
      currentTheta,
      currentTheta + TimePickerConstants.kTwoPi,
    );
    beginTheta = _nearest(
      targetTheta,
      beginTheta,
      currentTheta - TimePickerConstants.kTwoPi,
    );
    _thetaTween!
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController!
      ..value = 0.0
      ..forward();
  }

  double _getThetaForTime(
    TimeOfDayWithSecond? time,
  ) {
    final fraction = _getFraction(currentTime: time!);
    const rightAngle = math.pi / 2.0;

    /// calculates the angular position based on the fraction of
    /// the current time relative to the total time range.
    final angularPosition = fraction * TimePickerConstants.kTwoPi;

    /// Subtracting the calculated angular position from the right angle
    /// determines the angle with respect to
    /// the 12 o'clock position on the circle.
    final theta = (rightAngle - angularPosition) % TimePickerConstants.kTwoPi;

    return theta;
  }

  double _getFraction({
    required TimeOfDayWithSecond currentTime,
  }) {
    final hoursFactor = widget.use24HourDials
        ? TimeOfDay.hoursPerDay
        : TimeOfDay.hoursPerPeriod;

    final isSelectingHour = widget.mode == TimePickerUnit.hour;
    final isSelectingMinute = widget.mode == TimePickerUnit.minute;

    final hourFraction = (currentTime.hour / hoursFactor) % hoursFactor;

    final minuteFraction = (currentTime.minute / TimeOfDay.minutesPerHour) %
        TimeOfDay.minutesPerHour;

    final secondsFraction = (currentTime.second / TimeOfDay.minutesPerHour) %
        TimeOfDay.minutesPerHour;

    if (isSelectingHour) return hourFraction;
    if (isSelectingMinute) return minuteFraction;
    return secondsFraction;
  }

  TimeOfDayWithSecond _getTimeForTheta(
    double theta, {
    bool roundMinutes = false,
  }) {
    final fraction = (0.25 -
            (theta % TimePickerConstants.kTwoPi) / TimePickerConstants.kTwoPi) %
        1.0;
    TimeOfDayWithSecond newTime;
    if (widget.mode == TimePickerUnit.hour) {
      int newHour;
      if (widget.use24HourDials) {
        newHour =
            (fraction * TimeOfDay.hoursPerDay).round() % TimeOfDay.hoursPerDay;
      } else {
        newHour = (fraction * TimeOfDay.hoursPerPeriod).round() %
            TimeOfDay.hoursPerPeriod;
        newHour = newHour + widget.selectedTime.periodOffset;
      }
      newTime = widget.selectedTime.replacing(hour: newHour);
    } else if (widget.mode == TimePickerUnit.minute) {
      var minute = (fraction * TimeOfDay.minutesPerHour).round() %
          TimeOfDay.minutesPerHour;
      if (roundMinutes) {
        // Round the minutes to nearest 5 minute interval.
        minute = ((minute + 2) ~/ 5) * 5 % TimeOfDay.minutesPerHour;
      }
      newTime = widget.selectedTime.replacing(minute: minute);
    } else {
      final seconds = (fraction * 60).round() % 60;
      // if (roundMinutes) {
      // Round the minutes to nearest 5 minute interval.
      // seconds = ((seconds + 2) ~/ 5) * 5 % 60;
      // }
      newTime = widget.selectedTime.replacing(seconds: seconds);
    }
    if (TimePickerConstants.isSelectableTime(
      time: newTime,
      selectableTimePredicate: widget.selectableTimePredicate,
    )) {
      _lastSelectableTime = newTime;
    }
    return newTime;
  }

  TimeOfDayWithSecond _notifyOnChangedIfNeeded({bool roundMinutes = false}) {
    final current = _getTimeForTheta(_theta.value, roundMinutes: roundMinutes);
    // if (current != widget.selectedTime){
    widget.onChanged(current);
    // }
    return current;
  }

  void _updateThetaForPan({bool roundMinutes = false}) {
    setState(() {
      final offset = _position! - _center!;
      var angle = (math.atan2(offset.dx, offset.dy) - math.pi / 2.0) %
          TimePickerConstants.kTwoPi;
      if (roundMinutes) {
        angle = _getThetaForTime(
          _getTimeForTheta(angle, roundMinutes: roundMinutes),
        );
      }
      _thetaTween!
        ..begin = angle
        ..end = angle; // The controller doesn't animate during the pan gesture.
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging, 'Unexpected pan start callback when dragging.');
    _dragging = true;
    final box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    _updateThetaForPan();

    final newTime = _getTimeForTheta(_theta.value);
    if (TimePickerConstants.isSelectableTime(
      time: newTime,
      selectableTimePredicate: widget.selectableTimePredicate,
    )) {
      _notifyOnChangedIfNeeded();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging, 'Unexpected pan end callback when not dragging.');
    final newTime = _getTimeForTheta(_theta.value);
    _dragging = false;
    _position = null;
    _center = null;
    if (!TimePickerConstants.isSelectableTime(
      time: newTime,
      selectableTimePredicate: widget.selectableTimePredicate,
    )) {
      _animateTo(_getThetaForTime(_lastSelectableTime));
    } else {
      _animateTo(_getThetaForTime(widget.selectedTime));
      if (widget.mode == TimePickerUnit.hour) {
        // if (widget.onHourSelected != null) {
        widget.onHourSelected();
        // }
      } else if (widget.mode == TimePickerUnit.minute) {
        widget.onMinuteSelected();
      }
    }
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    final box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan(roundMinutes: true);

    final newTime = _getTimeForTheta(_theta.value);

    if (!TimePickerConstants.isSelectableTime(
      time: newTime,
      selectableTimePredicate: widget.selectableTimePredicate,
    )) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));
      _animateTo(_getThetaForTime(_lastSelectableTime));
      return;
    }

    if (widget.mode == TimePickerUnit.hour) {
      if (widget.use24HourDials) {
        TimePickerConstants.announceToAccessibility(
          context,
          localizations.formatDecimal(newTime.hour),
        );
      } else {
        TimePickerConstants.announceToAccessibility(
          context,
          localizations.formatDecimal(newTime.hourOfPeriod),
        );
      }
      // if (widget.onHourSelected != null) {
      widget.onHourSelected();
      // }
    } else if (widget.mode == TimePickerUnit.minute) {
      TimePickerConstants.announceToAccessibility(
        context,
        localizations.formatDecimal(newTime.minute),
      );

      widget.onMinuteSelected();
    } else if (widget.mode == TimePickerUnit.seconds) {
      TimePickerConstants.announceToAccessibility(
        context,
        localizations.formatDecimal(newTime.second),
      );
    }

    _animateTo(
      _getThetaForTime(
        _getTimeForTheta(
          _theta.value,
          roundMinutes: true,
        ),
      ),
    );
    _dragging = false;
    _position = null;
    _center = null;
    _notifyOnChangedIfNeeded();
  }

  void _selectHour(int hour) {
    TimePickerConstants.announceToAccessibility(
      context,
      localizations.formatDecimal(hour),
    );

    TimeOfDayWithSecond time;
    if (widget.mode == TimePickerUnit.hour && widget.use24HourDials) {
      time = TimeOfDayWithSecond(
        hour: hour,
        minute: widget.selectedTime.minute,
        second: widget.selectedTime.second,
      );
    } else {
      if (widget.selectedTime.period == DayPeriod.am) {
        time = TimeOfDayWithSecond(
          hour: hour,
          minute: widget.selectedTime.minute,
          second: widget.selectedTime.second,
        );
      } else {
        time = TimeOfDayWithSecond(
          hour: hour + TimeOfDay.hoursPerPeriod,
          minute: widget.selectedTime.minute,
          second: widget.selectedTime.second,
        );
      }
    }
    final angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectMinute(int minute) {
    TimePickerConstants.announceToAccessibility(
      context,
      localizations.formatDecimal(minute),
    );
    final time = TimeOfDayWithSecond(
      hour: widget.selectedTime.hour,
      minute: minute,
      second: widget.selectedTime.second,
    );
    final angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectSeconds(int seconds) {
    TimePickerConstants.announceToAccessibility(
      context,
      seconds.toString().padLeft(2, '0'),
    );
    final time = TimeOfDayWithSecond(
      hour: widget.selectedTime.hour,
      minute: widget.selectedTime.minute,
      second: seconds,
    );
    final angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  final _amHours = List.generate(
    12,
    (index) {
      final isMiddlePoint = index == 0;
      final value = isMiddlePoint ? 12 : index % 12;
      return TimeOfDayWithSecond(
        hour: value,
        minute: 0,
        second: 0,
      );
    },
  );

  final _twentyFourHours = List.generate(
    12,
    (index) {
      final value = index * 2;
      return TimeOfDayWithSecond(
        hour: value,
        minute: 0,
        second: 0,
      );
    },
  );

  TappableLabel _buildTappableLabel({
    required TextTheme textTheme,
    required Color color,
    required int value,
    required String label,
    VoidCallback? onTap,
  }) {
    final style = textTheme.bodyLarge!.copyWith(color: color);
    final double labelScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 2);
    return TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(style: style, text: label),
        textDirection: TextDirection.ltr,
        textScaleFactor: labelScaleFactor,
      )..layout(),
      onTap: onTap,
    );
  }

  List<TappableLabel> _build24HourRing(TextTheme textTheme, Color color) =>
      <TappableLabel>[
        for (final TimeOfDay timeOfDay in _twentyFourHours)
          _buildTappableLabel(
            textTheme: textTheme,
            color: color,
            value: timeOfDay.hour,
            label: localizations.formatHour(
              timeOfDay,
              alwaysUse24HourFormat: media.alwaysUse24HourFormat,
            ),
            onTap: () {
              _selectHour(timeOfDay.hour);
            },
          ),
      ];

  List<TappableLabel> _build12HourRing(TextTheme textTheme, Color color) =>
      <TappableLabel>[
        for (final TimeOfDayWithSecond timeOfDay in _amHours)
          _buildTappableLabel(
            textTheme: textTheme,
            color: TimePickerConstants.isSelectableTime(
              time: TimeOfDayWithSecond(
                hour: _buildHourFrom12HourRing(timeOfDay.hour),
                minute: timeOfDay.minute,
                second: timeOfDay.second,
              ),
              selectableTimePredicate: widget.selectableTimePredicate,
            )
                ? color
                : color.withOpacity(0.1),
            value: timeOfDay.hour,
            label: localizations.formatHour(
              timeOfDay,
              alwaysUse24HourFormat: media.alwaysUse24HourFormat,
            ),
            onTap: () {
              _selectHour(timeOfDay.hour);
            },
          ),
      ];

  int _buildHourFrom12HourRing(int hour) {
    if (hour == 12) {
      return (_isAM ? 0 : 12);
    }
    return hour + (_isAM ? 0 : 12);
  }

  List<TappableLabel> _buildMinutes(TextTheme textTheme, Color color) {
    const minuteMarkerValues = <TimeOfDayWithSecond>[
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 5, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 10, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 15, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 20, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 25, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 30, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 35, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 40, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 45, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 50, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 55, second: 0),
    ];

    return <TappableLabel>[
      for (final TimeOfDayWithSecond timeOfDay in minuteMarkerValues)
        _buildTappableLabel(
          textTheme: textTheme,
          color: TimePickerConstants.isSelectableTime(
            time: timeOfDay.replacing(hour: widget.selectedTime.hour),
            selectableTimePredicate: widget.selectableTimePredicate,
          )
              ? color
              : color.withOpacity(0.1),
          value: timeOfDay.minute,
          label: localizations.formatMinute(timeOfDay),
          onTap: () {
            _selectMinute(timeOfDay.minute);
          },
        ),
    ];
  }

  List<TappableLabel> _buildSeconds(
    TextTheme textTheme,
    Color color,
  ) {
    final secondsMarkerValues = List.generate(
      12,
      (index) => TimeOfDayWithSecond(
        hour: 0,
        minute: 0,
        second: index * 5,
      ),
    );

    final result = <TappableLabel>[
      for (final TimeOfDayWithSecond timeOfDay in secondsMarkerValues)
        _buildTappableLabel(
          textTheme: textTheme,
          color: TimePickerConstants.isSelectableTime(
            time: timeOfDay.replacing(
              hour: widget.selectedTime.hour,
            ),
            selectableTimePredicate: widget.selectableTimePredicate,
          )
              ? color
              : color.withOpacity(0.1),
          value: timeOfDay.second,
          label: timeOfDay.formatSeconds,
          onTap: () {
            _selectSeconds(timeOfDay.second);
          },
        ),
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickerTheme = TimePickerTheme.of(context);
    final backgroundColor = pickerTheme.dialBackgroundColor ??
        themeData.colorScheme.onBackground.withOpacity(0.12);

    final accentColor =
        pickerTheme.dialHandColor ?? themeData.colorScheme.primary;

    final primaryLabelColor = MaterialStateProperty.resolveAs(
          pickerTheme.dialTextColor,
          <MaterialState>{},
        ) ??
        themeData.colorScheme.onSurface;

    final secondaryLabelColor = MaterialStateProperty.resolveAs(
          pickerTheme.dialTextColor,
          <MaterialState>{MaterialState.selected},
        ) ??
        themeData.colorScheme.onPrimary;

    List<TappableLabel>? primaryLabels;
    List<TappableLabel>? secondaryLabels;
    int? selectedDialValue;

    switch (widget.mode) {
      case TimePickerUnit.hour:
        final secondary24 = _build24HourRing(
          theme.textTheme,
          secondaryLabelColor,
        );

        final secondary12 = _build12HourRing(
          theme.textTheme,
          secondaryLabelColor,
        );

        if (widget.use24HourDials) {
          selectedDialValue = widget.selectedTime.hour;
          primaryLabels = _build24HourRing(theme.textTheme, primaryLabelColor);
          secondaryLabels = secondary24;
        } else {
          selectedDialValue = widget.selectedTime.hourOfPeriod;
          primaryLabels = _build12HourRing(theme.textTheme, primaryLabelColor);
          secondaryLabels = secondary12;
        }
        break;
      case TimePickerUnit.seconds:
        selectedDialValue = widget.selectedTime.second;
        primaryLabels = _buildSeconds(theme.textTheme, primaryLabelColor);
        secondaryLabels = _buildSeconds(theme.textTheme, secondaryLabelColor);
        break;
      case TimePickerUnit.minute:
        selectedDialValue = widget.selectedTime.minute;
        primaryLabels = _buildMinutes(theme.textTheme, primaryLabelColor);
        secondaryLabels = _buildMinutes(theme.textTheme, secondaryLabelColor);
        break;
    }

    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        key: const ValueKey<String>('time-picker-dial'),
        painter: DialPainter(
          selectedValue: selectedDialValue,
          primaryLabels: primaryLabels,
          secondaryLabels: secondaryLabels,
          backgroundColor: backgroundColor,
          accentColor: accentColor,
          dotColor: theme.colorScheme.surface,
          theta: _theta.value,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}
