import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'time_of_day_with_second.dart';

/// Signature for predicating times for enabled time selections.
///
/// See [showTimePickerWithSecond], which has a [SelectableTimePredicate] parameter used
/// to specify allowable times in the time picker.
typedef SelectableTimePredicate = bool Function(TimeOfDayWithSecond time);

const Duration _kDialogSizeAnimationDuration = Duration(milliseconds: 200);
const Duration _kDialAnimateDuration = Duration(milliseconds: 200);
const double _kTwoPi = 2 * math.pi;
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

enum _TimePickerMode { hour, minute, seconds }

const double _kTimePickerHeaderLandscapeWidth = 264.0;
const double _kTimePickerHeaderControlHeight = 80.0;

const double _kTimePickerWidthPortrait = 328.0;
const double _kTimePickerWidthLandscape = 528.0;

const double _kTimePickerHeightInput = 226.0;
const double _kTimePickerHeightPortrait = 496.0;
const double _kTimePickerHeightLandscape = 316.0;

const double _kTimePickerHeightPortraitCollapsed = 484.0;
const double _kTimePickerHeightLandscapeCollapsed = 304.0;

const BorderRadius _kDefaultBorderRadius =
    BorderRadius.all(Radius.circular(4.0));
const ShapeBorder _kDefaultShape =
    RoundedRectangleBorder(borderRadius: _kDefaultBorderRadius);

/// Interactive input mode of the time picker dialog.
///
/// In [TimePickerEntryMode.dial] mode, a clock dial is displayed and
/// the user taps or drags the time they wish to select. In
/// TimePickerEntryMode.input] mode, [TextField]s are displayed and the user
/// types in the time they wish to select.
enum TimePickerEntryMode {
  /// Tapping/dragging on a clock dial.
  dial,

  /// Text input.
  input,
}

/// Provides properties for rendering time picker header fragments.
@immutable
class _TimePickerFragmentContext {
  const _TimePickerFragmentContext({
    required this.selectedTime,
    required this.mode,
    required this.onTimeChange,
    required this.onModeChange,
    required this.use24HourDials,
  });

  final TimeOfDayWithSecond selectedTime;
  final _TimePickerMode mode;
  final ValueChanged<TimeOfDayWithSecond> onTimeChange;
  final ValueChanged<_TimePickerMode> onModeChange;
  final bool use24HourDials;
}

class _TimePickerHeader extends StatelessWidget {
  const _TimePickerHeader({
    required this.selectedTime,
    required this.mode,
    required this.orientation,
    required this.onModeChanged,
    required this.onChanged,
    required this.use24HourDials,
    required this.helpText,
    this.selectableTimePredicate,
  });

  final TimeOfDayWithSecond selectedTime;
  final _TimePickerMode mode;
  final Orientation orientation;
  final ValueChanged<_TimePickerMode> onModeChanged;
  final ValueChanged<TimeOfDayWithSecond> onChanged;
  final bool use24HourDials;
  final String? helpText;
  final SelectableTimePredicate? selectableTimePredicate;

  void _handleChangeMode(_TimePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final ThemeData themeData = Theme.of(context);

    final TimeOfDayFormat timeOfDayFormat =
        MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

    final _TimePickerFragmentContext fragmentContext =
        _TimePickerFragmentContext(
      selectedTime: selectedTime,
      mode: mode,
      onTimeChange: onChanged,
      onModeChange: _handleChangeMode,
      use24HourDials: use24HourDials,
    );

    EdgeInsets? padding;
    double? width;
    Widget? controls;

    switch (orientation) {
      case Orientation.portrait:
        // Keep width null because in portrait we don't cap the width.
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        controls = Column(
          children: <Widget>[
            const SizedBox(height: 16.0),
            SizedBox(
              height: kMinInteractiveDimension * 2,
              child: Row(
                children: <Widget>[
                  if (!use24HourDials &&
                      timeOfDayFormat ==
                          TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                    _DayPeriodControl(
                      selectedTime: selectedTime,
                      orientation: orientation,
                      onChanged: onChanged,
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  Expanded(
                    child: Row(
                      // Hour/minutes should not change positions in RTL locales.
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        Expanded(
                          child: _HourControl(fragmentContext: fragmentContext),
                        ),
                        _StringFragment(timeOfDayFormat: timeOfDayFormat),
                        Expanded(
                          child:
                              _MinuteControl(fragmentContext: fragmentContext),
                        ),
                        _StringFragment(timeOfDayFormat: timeOfDayFormat),
                        Expanded(
                          child:
                              _SecondsControl(fragmentContext: fragmentContext),
                        ),
                      ],
                    ),
                  ),
                  if (!use24HourDials &&
                      timeOfDayFormat !=
                          TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                    const SizedBox(width: 12.0),
                    _DayPeriodControl(
                      selectedTime: selectedTime,
                      orientation: orientation,
                      onChanged: onChanged,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
        break;
      case Orientation.landscape:
        width = _kTimePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        controls = Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!use24HourDials &&
                  timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                _DayPeriodControl(
                  selectedTime: selectedTime,
                  orientation: orientation,
                  onChanged: onChanged,
                ),
              SizedBox(
                height: kMinInteractiveDimension * 2,
                child: Row(
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(
                      child: _HourControl(fragmentContext: fragmentContext),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: _MinuteControl(fragmentContext: fragmentContext),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: _SecondsControl(fragmentContext: fragmentContext),
                    ),
                  ],
                ),
              ),
              if (!use24HourDials &&
                  timeOfDayFormat != TimeOfDayFormat.a_space_h_colon_mm)
                _DayPeriodControl(
                  selectedTime: selectedTime,
                  orientation: orientation,
                  onChanged: onChanged,
                ),
            ],
          ),
        );
        break;
    }

    return Container(
      width: width,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16.0),
          Text(
            helpText ??
                MaterialLocalizations.of(context).timePickerDialHelpText,
            style: TimePickerTheme.of(context).helpTextStyle ??
                themeData.textTheme.labelSmall,
          ),
          controls,
        ],
      ),
    );
  }
}

class _HourMinuteControl extends StatelessWidget {
  const _HourMinuteControl({
    required this.text,
    required this.onTap,
    required this.isSelected,
  });

  final String text;
  final GestureTapCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final bool isDark = themeData.colorScheme.brightness == Brightness.dark;
    final Color textColor = timePickerTheme.hourMinuteTextColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? themeData.colorScheme.primary
              : themeData.colorScheme.onSurface;
        });
    final Color backgroundColor = timePickerTheme.hourMinuteColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? themeData.colorScheme.primary.withOpacity(isDark ? 0.24 : 0.12)
              : themeData.colorScheme.onSurface.withOpacity(0.12);
        });
    final TextStyle style =
        timePickerTheme.hourMinuteTextStyle ?? themeData.textTheme.displaySmall!;
    final ShapeBorder shape = timePickerTheme.hourMinuteShape ?? _kDefaultShape;

    final Set<MaterialState> states = isSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};
    return SizedBox(
      height: _kTimePickerHeaderControlHeight,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, states),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: style.copyWith(
                color: MaterialStateProperty.resolveAs(
                  textColor,
                  states,
                ),
              ),
              textScaleFactor: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [_TimePickerMode.hour].
class _HourControl extends StatelessWidget {
  const _HourControl({
    required this.fragmentContext,
  });

  final _TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool alwaysUse24HourFormat =
        MediaQuery.of(context).alwaysUse24HourFormat;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String formattedHour = localizations.formatHour(
      fragmentContext.selectedTime,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    TimeOfDayWithSecond hoursFromSelected(int hoursToAdd) {
      if (fragmentContext.use24HourDials) {
        final int selectedHour = fragmentContext.selectedTime.hour;
        return fragmentContext.selectedTime.replacing(
          hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
        );
      } else {
        // Cycle 1 through 12 without changing day period.
        final int periodOffset = fragmentContext.selectedTime.periodOffset;
        final int hours = fragmentContext.selectedTime.hourOfPeriod;
        return fragmentContext.selectedTime.replacing(
          hour: periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
        );
      }
    }

    final TimeOfDayWithSecond nextHour = hoursFromSelected(1);

    final String formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final TimeOfDayWithSecond previousHour = hoursFromSelected(-1);

    final String formattedPreviousHour = localizations.formatHour(
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
      child: _HourMinuteControl(
        isSelected: fragmentContext.mode == _TimePickerMode.hour,
        text: formattedHour,
        onTap: Feedback.wrapForTap(
          () => fragmentContext.onModeChange(_TimePickerMode.hour),
          context,
        )!,
      ),
    );
  }
}

/// A passive fragment showing a string value.
class _StringFragment extends StatelessWidget {
  const _StringFragment({
    required this.timeOfDayFormat,
  });

  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    String result = '';
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
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final TextStyle hourMinuteStyle =
        timePickerTheme.hourMinuteTextStyle ?? theme.textTheme.displaySmall!;
    final Color textColor =
        timePickerTheme.hourMinuteTextColor ?? theme.colorScheme.onSurface;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Center(
          child: Text(
            _stringFragmentValue(timeOfDayFormat),
            style: hourMinuteStyle.apply(
              color: MaterialStateProperty.resolveAs(
                textColor,
                <MaterialState>{},
              ),
            ),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_TimePickerMode.minute].
class _MinuteControl extends StatelessWidget {
  const _MinuteControl({
    required this.fragmentContext,
  });

  final _TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final String formattedMinute =
        localizations.formatMinute(fragmentContext.selectedTime);

    final TimeOfDayWithSecond nextMinute =
        fragmentContext.selectedTime.replacing(
      minute:
          (fragmentContext.selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );

    final String formattedNextMinute = localizations.formatMinute(nextMinute);

    final TimeOfDayWithSecond previousMinute =
        fragmentContext.selectedTime.replacing(
      minute:
          (fragmentContext.selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );

    final String formattedPreviousMinute =
        localizations.formatMinute(previousMinute);

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
      child: _HourMinuteControl(
        isSelected: fragmentContext.mode == _TimePickerMode.minute,
        text: formattedMinute,
        onTap: Feedback.wrapForTap(
            () => fragmentContext.onModeChange(_TimePickerMode.minute),
            context)!,
      ),
    );
  }
}

/// Display The Seconds Picker
class _SecondsControl extends StatelessWidget {
  const _SecondsControl({
    required this.fragmentContext,
  });

  final _TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final String formattedSeconds =
        (fragmentContext.selectedTime.formatSeconds());

    final TimeOfDayWithSecond nextSecond =
        fragmentContext.selectedTime.replacing(
      seconds:
          (fragmentContext.selectedTime.second + 1) % TimeOfDay.minutesPerHour,
    );

    final String formattedNextSecond = (nextSecond.formatSeconds());

    final TimeOfDayWithSecond previousSecond =
        fragmentContext.selectedTime.replacing(
      seconds:
          (fragmentContext.selectedTime.second - 1) % TimeOfDay.minutesPerHour,
    );

    final String formattedPreviousSecond = (previousSecond.formatSeconds());

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
      child: _HourMinuteControl(
        isSelected: fragmentContext.mode == _TimePickerMode.seconds,
        text: formattedSeconds,
        onTap: Feedback.wrapForTap(
            () => fragmentContext.onModeChange(_TimePickerMode.seconds),
            context)!,
      ),
    );
  }
}

/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class _DayPeriodControl extends StatelessWidget {
  const _DayPeriodControl({
    required this.selectedTime,
    required this.onChanged,
    required this.orientation,
  });

  final TimeOfDayWithSecond? selectedTime;
  final Orientation orientation;
  final ValueChanged<TimeOfDayWithSecond> onChanged;

  void _togglePeriod() {
    final int newHour =
        (selectedTime!.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final TimeOfDayWithSecond newTime = selectedTime!.replacing(hour: newHour);
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
        _announceToAccessibility(context,
            MaterialLocalizations.of(context).anteMeridiemAbbreviation);
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
        _announceToAccessibility(context,
            MaterialLocalizations.of(context).postMeridiemAbbreviation);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color textColor = timePickerTheme.dayPeriodTextColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.60);
        });
    final Color backgroundColor = timePickerTheme.dayPeriodColor ??
        MaterialStateColor.resolveWith((Set<MaterialState> states) {
          // The unselected day period should match the overall picker dialog
          // color. Making it transparent enables that without being redundant
          // and allows the optional elevation overlay for dark mode to be
          // visible.
          return states.contains(MaterialState.selected)
              ? colorScheme.primary.withOpacity(isDark ? 0.24 : 0.12)
              : Colors.transparent;
        });
    final bool amSelected = selectedTime!.period == DayPeriod.am;
    final Set<MaterialState> amStates = amSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};
    final bool pmSelected = !amSelected;
    final Set<MaterialState> pmStates = pmSelected
        ? <MaterialState>{MaterialState.selected}
        : <MaterialState>{};
    final TextStyle textStyle = timePickerTheme.dayPeriodTextStyle ??
        Theme.of(context).textTheme.titleMedium!;
    final TextStyle amStyle = textStyle.copyWith(
      color: MaterialStateProperty.resolveAs(textColor, amStates),
    );
    final TextStyle pmStyle = textStyle.copyWith(
      color: MaterialStateProperty.resolveAs(textColor, pmStates),
    );
    OutlinedBorder shape = timePickerTheme.dayPeriodShape ??
        const RoundedRectangleBorder(borderRadius: _kDefaultBorderRadius);
    final BorderSide borderSide = timePickerTheme.dayPeriodBorderSide ??
        BorderSide(
          color: Color.alphaBlend(
              colorScheme.onBackground.withOpacity(0.38), colorScheme.surface),
        );
    // Apply the custom borderSide.
    shape = shape.copyWith(
      side: borderSide,
    );

    final double buttonTextScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 2.0);

    final hours = List.generate(
        12, (index) => TimeOfDayWithSecond(hour: index, minute: 0, second: 0));
    final bool hasAMHours = hours.where((h) => _isSelectableTime(h)).isNotEmpty;
    final bool hasPMHours = hours
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
        ));

    late Widget result;
    switch (orientation) {
      case Orientation.portrait:
        const double width = 52.0;
        result = _DayPeriodInputPadding(
          minSize: const Size(width, kMinInteractiveDimension * 2),
          orientation: orientation,
          child: SizedBox(
            width: width,
            height: _kTimePickerHeaderControlHeight,
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
        result = _DayPeriodInputPadding(
          minSize: const Size(0.0, kMinInteractiveDimension),
          orientation: orientation,
          child: SizedBox(
            height: 40.0,
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

/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
class _DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  const _DayPeriodInputPadding({
    Key? key,
    Widget? child,
    this.minSize,
    this.orientation,
  }) : super(key: key, child: child);

  final Size? minSize;
  final Orientation? orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize, orientation);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderInputPadding renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, this.orientation, [RenderBox? child])
      : super(child);

  final Orientation? orientation;

  Size? get minSize => _minSize;
  Size? _minSize;

  set minSize(Size? value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize!.width);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize!.height);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize!.width);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize!.height);
    }
    return 0.0;
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      final double width = math.max(child!.size.width, minSize!.width);
      final double height = math.max(child!.size.height, minSize!.height);
      size = constraints.constrain(Size(width, height));
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset =
          Alignment.center.alongOffset(size - child!.size as Offset);
    } else {
      size = Size.zero;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (position.dx < 0.0 ||
        position.dx > math.max(child!.size.width, minSize!.width) ||
        position.dy < 0.0 ||
        position.dy > math.max(child!.size.height, minSize!.height)) {
      return false;
    }

    Offset newPosition = child!.size.center(Offset.zero);
    switch (orientation) {
      case null:
        break;
      case Orientation.portrait:
        if (position.dy > newPosition.dy) {
          newPosition += const Offset(0.0, 1.0);
        } else {
          newPosition += const Offset(0.0, -1.0);
        }
        break;
      case Orientation.landscape:
        if (position.dx > newPosition.dx) {
          newPosition += const Offset(1.0, 0.0);
        } else {
          newPosition += const Offset(-1.0, 0.0);
        }
        break;
    }

    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(newPosition),
      position: newPosition,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == newPosition);
        return child!.hitTest(result, position: newPosition);
      },
    );
  }
}

class _TappableLabel {
  _TappableLabel({
    required this.value,
    required this.painter,
    required this.onTap,
  });

  /// The value this label is displaying.
  final int value;

  /// Paints the text of the label.
  final TextPainter painter;

  /// Called when a tap gesture is detected on the label.
  final VoidCallback? onTap;
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.primaryLabels,
    required this.secondaryLabels,
    required this.backgroundColor,
    required this.accentColor,
    required this.dotColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
  }) : super(repaint: PaintingBinding.instance.systemFonts);

  final List<_TappableLabel>? primaryLabels;
  final List<_TappableLabel>? secondaryLabels;
  final Color backgroundColor;
  final Color accentColor;
  final Color dotColor;
  final double theta;
  final TextDirection textDirection;
  final int? selectedValue;

  static const double _labelPadding = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2.0;
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final Offset centerPoint = center;
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor);

    final double labelRadius = radius - _labelPadding;
    Offset getOffsetForTheta(double theta) {
      return center +
          Offset(labelRadius * math.cos(theta), -labelRadius * math.sin(theta));
    }

    void paintLabels(List<_TappableLabel>? labels) {
      if (labels == null) return;
      final double labelThetaIncrement = -_kTwoPi / labels.length;
      double labelTheta = math.pi / 2.0;

      for (final _TappableLabel label in labels) {
        final TextPainter labelPainter = label.painter;
        final Offset labelOffset =
            Offset(-labelPainter.width / 2.0, -labelPainter.height / 2.0);
        labelPainter.paint(canvas, getOffsetForTheta(labelTheta) + labelOffset);
        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(primaryLabels);

    final Paint selectorPaint = Paint()..color = accentColor;
    final Offset focusedPoint = getOffsetForTheta(theta);
    const double focusedRadius = _labelPadding - 4.0;
    canvas.drawCircle(centerPoint, 4.0, selectorPaint);
    canvas.drawCircle(focusedPoint, focusedRadius, selectorPaint);
    selectorPaint.strokeWidth = 2.0;
    canvas.drawLine(centerPoint, focusedPoint, selectorPaint);

    // Add a dot inside the selector but only when it isn't over the labels.
    // This checks that the selector's theta is between two labels. A remainder
    // between 0.1 and 0.45 indicates that the selector is roughly not above any
    // labels. The values were derived by manually testing the dial.
    final double labelThetaIncrement = -_kTwoPi / primaryLabels!.length;
    if (theta % labelThetaIncrement > 0.1 &&
        theta % labelThetaIncrement < 0.45) {
      canvas.drawCircle(focusedPoint, 2.0, selectorPaint..color = dotColor);
    }

    final Rect focusedRect = Rect.fromCircle(
      center: focusedPoint,
      radius: focusedRadius,
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(focusedRect));
    paintLabels(secondaryLabels);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter oldPainter) {
    return oldPainter.primaryLabels != primaryLabels ||
        oldPainter.secondaryLabels != secondaryLabels ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.accentColor != accentColor ||
        oldPainter.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.selectedTime,
    required this.mode,
    required this.use24HourDials,
    required this.onChanged,
    required this.onHourSelected,
    required this.onMinuteSelected,
    this.selectableTimePredicate,
  });

  final TimeOfDayWithSecond selectedTime;
  final _TimePickerMode mode;
  final bool use24HourDials;
  final ValueChanged<TimeOfDayWithSecond> onChanged;
  final VoidCallback onHourSelected;
  final VoidCallback onMinuteSelected;
  final SelectableTimePredicate? selectableTimePredicate;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  TimeOfDayWithSecond? _lastSelectableTime;

  bool get _isAM => widget.selectedTime.period == DayPeriod.am;

  @override
  void initState() {
    super.initState();
    _lastSelectableTime = widget.selectedTime;
    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(begin: _getThetaForTime(widget.selectedTime));
    _theta = _thetaController!
        .drive(CurveTween(curve: Curves.easeIn))
        .drive(_thetaTween!)
      ..addListener(() => setState(() {
            /* _theta.value has changed */
          }));
  }

  late ThemeData themeData;
  late MaterialLocalizations localizations;
  late MediaQueryData media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void didUpdateWidget(_Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode ||
        widget.selectedTime != oldWidget.selectedTime) {
      if (!_dragging) _animateTo(_getThetaForTime(widget.selectedTime));
    }
  }

  @override
  void dispose() {
    _thetaController!.dispose();
    super.dispose();
  }

  Tween<double>? _thetaTween;
  late Animation<double> _theta;
  AnimationController? _thetaController;
  bool _dragging = false;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final double currentTheta = _theta.value;
    double beginTheta =
        _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween!
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController!
      ..value = 0.0
      ..forward();
  }

  double _getThetaForTime(TimeOfDayWithSecond? time) {
    final int hoursFactor = widget.use24HourDials
        ? TimeOfDay.hoursPerDay
        : TimeOfDay.hoursPerPeriod;
    final double fraction = widget.mode == _TimePickerMode.hour
        ? (time!.hour / hoursFactor) % hoursFactor
        : (widget.mode == _TimePickerMode.minute)
            ? (time!.minute / TimeOfDay.minutesPerHour) %
                TimeOfDay.minutesPerHour
            : (time!.second / TimeOfDay.minutesPerHour) %
                TimeOfDay.minutesPerHour;
    return (math.pi / 2.0 - fraction * _kTwoPi) % _kTwoPi;
  }

  TimeOfDayWithSecond _getTimeForTheta(double theta,
      {bool roundMinutes = false}) {
    final double fraction = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;
    TimeOfDayWithSecond newTime;
    if (widget.mode == _TimePickerMode.hour) {
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
    } else if (widget.mode == _TimePickerMode.minute) {
      int minute = (fraction * TimeOfDay.minutesPerHour).round() %
          TimeOfDay.minutesPerHour;
      if (roundMinutes) {
        // Round the minutes to nearest 5 minute interval.
        minute = ((minute + 2) ~/ 5) * 5 % TimeOfDay.minutesPerHour;
      }
      newTime = widget.selectedTime.replacing(minute: minute);
    } else {
      int seconds = (fraction * 60).round() % 60;
      // if (roundMinutes) {
      // Round the minutes to nearest 5 minute interval.
      // seconds = ((seconds + 2) ~/ 5) * 5 % 60;
      // }
      newTime = widget.selectedTime.replacing(seconds: seconds);
    }
    if (_isSelectableTime(newTime)) _lastSelectableTime = newTime;
    return newTime;
  }

  TimeOfDayWithSecond _notifyOnChangedIfNeeded({bool roundMinutes = false}) {
    final TimeOfDayWithSecond current =
        _getTimeForTheta(_theta.value, roundMinutes: roundMinutes);
    // if (current != widget.selectedTime){
    widget.onChanged(current);
    // }
    return current;
  }

  void _updateThetaForPan({bool roundMinutes = false}) {
    setState(() {
      final Offset offset = _position! - _center!;
      double angle =
          (math.atan2(offset.dx, offset.dy) - math.pi / 2.0) % _kTwoPi;
      if (roundMinutes) {
        angle = _getThetaForTime(
            _getTimeForTheta(angle, roundMinutes: roundMinutes));
      }
      _thetaTween!
        ..begin = angle
        ..end = angle; // The controller doesn't animate during the pan gesture.
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final RenderBox box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    _updateThetaForPan();

    final TimeOfDayWithSecond newTime =
        _getTimeForTheta(_theta.value, roundMinutes: false);
    if (_isSelectableTime(newTime)) _notifyOnChangedIfNeeded();
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    final TimeOfDayWithSecond newTime =
        _getTimeForTheta(_theta.value, roundMinutes: false);
    _dragging = false;
    _position = null;
    _center = null;
    if (!_isSelectableTime(newTime)) {
      _animateTo(_getThetaForTime(_lastSelectableTime));
    } else {
      _animateTo(_getThetaForTime(widget.selectedTime));
      if (widget.mode == _TimePickerMode.hour) {
        // if (widget.onHourSelected != null) {
        widget.onHourSelected();
        // }
      } else if (widget.mode == _TimePickerMode.minute) {
        widget.onMinuteSelected();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan(roundMinutes: true);

    final TimeOfDayWithSecond newTime =
        _getTimeForTheta(_theta.value, roundMinutes: false);

    if (!_isSelectableTime(newTime)) {
      await Future.delayed(const Duration(milliseconds: 100));
      _animateTo(_getThetaForTime(_lastSelectableTime));
      return;
    }

    if (widget.mode == _TimePickerMode.hour) {
      if (widget.use24HourDials) {
        _announceToAccessibility(
            context, localizations.formatDecimal(newTime.hour));
      } else {
        _announceToAccessibility(
            context, localizations.formatDecimal(newTime.hourOfPeriod));
      }
      // if (widget.onHourSelected != null) {
      widget.onHourSelected();
      // }
    } else if (widget.mode == _TimePickerMode.minute) {
      _announceToAccessibility(
          context, localizations.formatDecimal(newTime.minute));

      widget.onMinuteSelected();
    } else if (widget.mode == _TimePickerMode.seconds) {
      _announceToAccessibility(
          context, localizations.formatDecimal(newTime.second));
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
    _announceToAccessibility(context, localizations.formatDecimal(hour));
    TimeOfDayWithSecond time;
    if (widget.mode == _TimePickerMode.hour && widget.use24HourDials) {
      time = TimeOfDayWithSecond(
          hour: hour,
          minute: widget.selectedTime.minute,
          second: widget.selectedTime.second);
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
    final double angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectMinute(int minute) {
    _announceToAccessibility(context, localizations.formatDecimal(minute));
    final TimeOfDayWithSecond time = TimeOfDayWithSecond(
      hour: widget.selectedTime.hour,
      minute: minute,
      second: widget.selectedTime.second,
    );
    final double angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectSeconds(int seconds) {
    _announceToAccessibility(context, seconds.toString().padLeft(2, '0'));
    final TimeOfDayWithSecond time = TimeOfDayWithSecond(
      hour: widget.selectedTime.hour,
      minute: widget.selectedTime.minute,
      second: seconds,
    );
    final double angle = _getThetaForTime(time);
    _thetaTween!
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  static const List<TimeOfDayWithSecond> _amHours = <TimeOfDayWithSecond>[
    TimeOfDayWithSecond(hour: 12, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 1, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 2, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 3, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 4, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 5, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 6, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 7, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 8, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 9, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 10, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 11, minute: 0, second: 0),
  ];

  static const List<TimeOfDayWithSecond> _twentyFourHours =
      <TimeOfDayWithSecond>[
    TimeOfDayWithSecond(hour: 12, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 1, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 2, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 3, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 4, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 5, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 6, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 7, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 8, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 9, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 10, minute: 0, second: 0),
    TimeOfDayWithSecond(hour: 11, minute: 0, second: 0),
  ];

  _TappableLabel _buildTappableLabel({
    required TextTheme textTheme,
    required Color color,
    required int value,
    required String label,
    VoidCallback? onTap,
  }) {
    final TextStyle style = textTheme.bodyLarge!.copyWith(color: color);
    final double labelScaleFactor =
        math.min(MediaQuery.of(context).textScaleFactor, 2.0);
    return _TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(style: style, text: label),
        textDirection: TextDirection.ltr,
        textScaleFactor: labelScaleFactor,
      )..layout(),
      onTap: onTap,
    );
  }

  List<_TappableLabel> _build24HourRing(TextTheme textTheme, Color color) =>
      <_TappableLabel>[
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

  List<_TappableLabel> _build12HourRing(TextTheme textTheme, Color color) =>
      <_TappableLabel>[
        for (final TimeOfDayWithSecond timeOfDay in _amHours)
          _buildTappableLabel(
            textTheme: textTheme,
            color: _isSelectableTime(TimeOfDayWithSecond(
              hour: _buildHourFrom12HourRing(timeOfDay.hour),
              minute: timeOfDay.minute,
              second: timeOfDay.second,
            ))
                ? color
                : color.withOpacity(0.1),
            value: timeOfDay.hour,
            label: localizations.formatHour(timeOfDay,
                alwaysUse24HourFormat: media.alwaysUse24HourFormat),
            onTap: () {
              _selectHour(timeOfDay.hour);
            },
          ),
      ];

  int _buildHourFrom12HourRing(int hour) {
    if (hour == 12) {
      hour = 0;
    }

    return hour + (_isAM ? 0 : 12);
  }

  List<_TappableLabel> _buildMinutes(TextTheme textTheme, Color color) {
    const List<TimeOfDayWithSecond> minuteMarkerValues = <TimeOfDayWithSecond>[
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

    return <_TappableLabel>[
      for (final TimeOfDayWithSecond timeOfDay in minuteMarkerValues)
        _buildTappableLabel(
          textTheme: textTheme,
          color: _isSelectableTime(
                  timeOfDay.replacing(hour: widget.selectedTime.hour))
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

  List<_TappableLabel> _buildSeconds(TextTheme textTheme, Color color) {
    const List<TimeOfDayWithSecond> secondsMarkerValues = <TimeOfDayWithSecond>[
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 0),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 5),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 10),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 15),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 20),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 25),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 30),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 35),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 40),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 45),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 50),
      TimeOfDayWithSecond(hour: 0, minute: 0, second: 55),
    ];

    final result = <_TappableLabel>[
      for (final TimeOfDayWithSecond timeOfDay in secondsMarkerValues)
        _buildTappableLabel(
          textTheme: textTheme,
          color: _isSelectableTime(
            timeOfDay.replacing(
              hour: widget.selectedTime.hour,
            ),
          )
              ? color
              : color.withOpacity(0.1),
          value: timeOfDay.second,
          label: timeOfDay.formatSeconds(),
          onTap: () {
            _selectSeconds(timeOfDay.second);
          },
        ),
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData pickerTheme = TimePickerTheme.of(context);
    final Color backgroundColor = pickerTheme.dialBackgroundColor ??
        themeData.colorScheme.onBackground.withOpacity(0.12);
    final Color accentColor =
        pickerTheme.dialHandColor ?? themeData.colorScheme.primary;
    final Color primaryLabelColor = MaterialStateProperty.resolveAs(
            pickerTheme.dialTextColor, <MaterialState>{}) ??
        themeData.colorScheme.onSurface;
    final Color secondaryLabelColor = MaterialStateProperty.resolveAs(
            pickerTheme.dialTextColor,
            <MaterialState>{MaterialState.selected}) ??
        themeData.colorScheme.onPrimary;
    List<_TappableLabel>? primaryLabels;
    List<_TappableLabel>? secondaryLabels;
    int? selectedDialValue;
    switch (widget.mode) {
      case _TimePickerMode.hour:
        if (widget.use24HourDials) {
          selectedDialValue = widget.selectedTime.hour;
          primaryLabels = _build24HourRing(theme.textTheme, primaryLabelColor);
          secondaryLabels = _build24HourRing(
            theme
                .copyWith(
                  colorScheme: theme.colorScheme
                      .copyWith(secondary: theme.colorScheme.onSecondary),
                )
                .textTheme,
            secondaryLabelColor,
          );
        } else {
          selectedDialValue = widget.selectedTime.hourOfPeriod;
          primaryLabels = _build12HourRing(theme.textTheme, primaryLabelColor);
          secondaryLabels = _build24HourRing(
            theme
                .copyWith(
                  colorScheme: theme.colorScheme
                      .copyWith(secondary: theme.colorScheme.onSecondary),
                )
                .textTheme,
            secondaryLabelColor,
          );
        }
        break;
      case _TimePickerMode.seconds:
        selectedDialValue = widget.selectedTime.second;
        primaryLabels = _buildSeconds(theme.textTheme, primaryLabelColor);
        secondaryLabels = _build24HourRing(
          theme
              .copyWith(
                colorScheme: theme.colorScheme
                    .copyWith(secondary: theme.colorScheme.onSecondary),
              )
              .textTheme,
          secondaryLabelColor,
        );
        break;
      case _TimePickerMode.minute:
        selectedDialValue = widget.selectedTime.minute;
        primaryLabels = _buildMinutes(theme.textTheme, primaryLabelColor);
        secondaryLabels = _build24HourRing(
          theme
              .copyWith(
                colorScheme: theme.colorScheme
                    .copyWith(secondary: theme.colorScheme.onSecondary),
              )
              .textTheme,
          secondaryLabelColor,
        );
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
        painter: _DialPainter(
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

/// A material design time picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [TimeOfDay] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class _TimePickerDialog extends StatefulWidget {
  /// Creates a material time picker.
  ///
  /// [initialTime] must not be null.
  _TimePickerDialog({
    Key? key,
    required this.initialTime,
    required this.cancelText,
    required this.confirmText,
    required this.helpText,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.selectableTimePredicate,
  }) : super(key: key) {
    assert(
        selectableTimePredicate == null ||
            selectableTimePredicate!(initialTime),
        'Provided initialTime $initialTime must satisfy provided selectableTimePredicate.');
  }

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
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
  _TimePickerMode _mode = _TimePickerMode.hour;
  _TimePickerMode? _lastModeAnnounced;

//   bool _autoValidate;

  TimeOfDayWithSecond? get selectedTime => _selectedTime;
  TimeOfDayWithSecond? _selectedTime;

  SelectableTimePredicate? _selectableTimePredicate;

  Timer? _vibrateTimer;
  late MaterialLocalizations localizations;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _vibrateTimer?.cancel();
        _vibrateTimer = Timer(_kVibrateCommitDelay, () {
          HapticFeedback.vibrate();
          _vibrateTimer = null;
        });
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(_TimePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
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
    if (_lastModeAnnounced == _mode) {
      // Already announced it.
      return;
    }

    switch (_mode) {
      case _TimePickerMode.hour:
        _announceToAccessibility(
            context, localizations.timePickerHourModeAnnouncement);
        break;
      case _TimePickerMode.seconds:
        _announceToAccessibility(
            context, localizations.timePickerMinuteModeAnnouncement);
        break;
      case _TimePickerMode.minute:
        _announceToAccessibility(
            context, localizations.timePickerMinuteModeAnnouncement);
        break;
    }
    _lastModeAnnounced = _mode;
  }

  bool _announcedInitialTime = false;

  void _announceInitialTimeOnce() {
    if (_announcedInitialTime) return;

    final MediaQueryData media = MediaQuery.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    _announceToAccessibility(
      context,
      localizations.formatTimeOfDay(widget.initialTime,
          alwaysUse24HourFormat: media.alwaysUse24HourFormat),
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
      _mode = _TimePickerMode.minute;
    });
  }

  void _handleMinuteSelected() {
    setState(() {
      _mode = _TimePickerMode.seconds;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    if (!_isSelectableTime(selectedTime)) {
      _notifyFailValidation();
      return;
    }

    if (_entryMode == TimePickerEntryMode.input) {
      final FormState form = _formKey.currentState!;
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
    final Orientation orientation = MediaQuery.of(context).orientation;
    final ThemeData theme = Theme.of(context);
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
            timePickerWidth = _kTimePickerWidthPortrait;
            timePickerHeight =
                theme.materialTapTargetSize == MaterialTapTargetSize.padded
                    ? _kTimePickerHeightPortrait
                    : _kTimePickerHeightPortraitCollapsed;
            break;
          case Orientation.landscape:
            timePickerWidth = _kTimePickerWidthLandscape * textScaleFactor;
            timePickerHeight =
                theme.materialTapTargetSize == MaterialTapTargetSize.padded
                    ? _kTimePickerHeightLandscape
                    : _kTimePickerHeightLandscapeCollapsed;
            break;
        }
        break;
      case TimePickerEntryMode.input:
        timePickerWidth = _kTimePickerWidthPortrait;
        timePickerHeight = _kTimePickerHeightInput;
        break;
    }
    return Size(timePickerWidth, timePickerHeight * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData media = MediaQuery.of(context);
//     final TimeOfDayFormat timeOfDayFormat = localizations.timeOfDayFormat(
//         alwaysUse24HourFormat: false //media.alwaysUse24HourFormat
//         );
    const bool use24HourDials =
        false; // hourFormat(of: timeOfDayFormat) != HourFormat.h;
    final ThemeData theme = Theme.of(context);
    final ShapeBorder shape =
        TimePickerTheme.of(context).shape ?? _kDefaultShape;
    final Orientation orientation = media.orientation;

    final Widget actions = Row(
      children: <Widget>[
        const SizedBox(width: 10.0),
        // IconButton(
        //   color: TimePickerTheme.of(context).entryModeIconColor ??
        //       theme.colorScheme.onSurface.withOpacity(
        //         theme.colorScheme.brightness == Brightness.dark ? 1.0 : 0.6,
        //       ),
        //   onPressed: _handleEntryModeToggle,
        //   icon: Icon(_entryMode == TimePickerEntryMode.dial
        //       ? Icons.keyboard
        //       : Icons.access_time),
        //   tooltip: _entryMode == TimePickerEntryMode.dial
        //       ? MaterialLocalizations.of(context).inputTimeModeButtonLabel
        //       : MaterialLocalizations.of(context).dialModeButtonLabel,
        // ),
        Expanded(
          child: ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: <Widget>[
              TextButton(
                onPressed: _handleCancel,
                child:
                    Text(widget.cancelText ?? localizations.cancelButtonLabel),
              ),
              TextButton(
                onPressed: _handleOk,
                child: Text(widget.confirmText ?? localizations.okButtonLabel),
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
              aspectRatio: 1.0,
              child: _Dial(
                mode: _mode,
                use24HourDials: use24HourDials,
                selectedTime: _selectedTime!,
                onChanged: _handleTimeChanged,
                onHourSelected: _handleHourSelected,
                onMinuteSelected: _handleMinuteSelected,
                selectableTimePredicate: _selectableTimePredicate,
              ),
            ),
          ),
        );

        final Widget header = _TimePickerHeader(
          selectedTime: _selectedTime!,
          mode: _mode,
          orientation: orientation,
          onModeChanged: _handleModeChanged,
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
//         picker = Form(
//           key: _formKey,
// //           autovalidate: _autoValidate,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 _TimePickerInput(
//                   initialSelectedTime: _selectedTime!,
//                   helpText: widget.helpText,
//                   onChanged: _handleTimeChanged,
//                 ),
//                 actions,
//               ],
//             ),
//           ),
//         );
        break;
    }

    final Size dialogSize = _dialogSize(context);
    return Dialog(
      shape: shape,
      backgroundColor: TimePickerTheme.of(context).backgroundColor ??
          theme.colorScheme.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: _entryMode == TimePickerEntryMode.input ? 0.0 : 24.0,
      ),
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _kDialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: picker,
      ),
    );
  }

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }
}

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
/// The [context], [useRootNavigator] and [routeSettings] arguments are passed to
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
  Function(BuildContext)? onFailValidation,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));
  assert(onFailValidation != null || selectableTimePredicate == null,
      "'onFailValidation' can't be null if 'selectableTimePredicate' has been set");

  _isSelectableTime = (time) => selectableTimePredicate?.call(time) ?? true;

  final Widget dialog = _TimePickerDialog(
      initialTime: initialTime,
      initialEntryMode: initialEntryMode,
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
      selectableTimePredicate: selectableTimePredicate);
  return await showDialog<TimeOfDayWithSecond>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      _notifyFailValidation = () => onFailValidation?.call(context);
      return builder == null ? dialog : builder(context, dialog);
    },
    routeSettings: routeSettings,
  );
}

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}

late bool Function(TimeOfDayWithSecond? time) _isSelectableTime;
late Function() _notifyFailValidation;
