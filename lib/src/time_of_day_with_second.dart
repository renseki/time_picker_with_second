import 'package:flutter/material.dart';

/// An extended version of [TimeOfDay] that includes seconds.
class TimeOfDayWithSecond extends TimeOfDay {
  /// Creates a time of day.
  const TimeOfDayWithSecond({
    required this.second,
    required super.hour,
    required super.minute,
  });

  /// Named constructor to create a time of day based on the given time.
  TimeOfDayWithSecond.fromDateTime(super.dateTime)
      : second = dateTime.second,
        super.fromDateTime();

  /// Adding the [second] property to the existing [TimeOfDay] class.
  final int second;

  /// Constants that represent the number of seconds in a minute.
  static const int secondsPerMinute = 60;

  /// getter method which formats the seconds to a two digit string.
  String get formatSeconds => second.toString().padLeft(2, '0');

  @override
  TimeOfDayWithSecond replacing({
    int? hour,
    int? minute,
    int? seconds,
  }) {
    return TimeOfDayWithSecond(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: seconds ?? second,
    );
  }

  @override
  String toString() {
    /// A method to pad the hour, minute
    /// and second with a leading zero if needed.
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(minute);
    final twoDigitSeconds = twoDigits(second);
    return '$hour:$twoDigitMinutes:$twoDigitSeconds';
  }
}
