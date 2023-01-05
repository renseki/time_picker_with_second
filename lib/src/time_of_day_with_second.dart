import 'package:flutter/material.dart';

class TimeOfDayWithSecond extends TimeOfDay {
  final int second;

  const TimeOfDayWithSecond(
      {required this.second, required int hour, required int minute})
      : super(hour: hour, minute: minute);

  static const int secondsPerMinute = 60;

  TimeOfDayWithSecond.fromDateTime(DateTime dateTime)
      : second = dateTime.second,
        super.fromDateTime(dateTime);

  String formatSeconds() {
    return second.toString().padLeft(2, '0');
  }

  @override
  TimeOfDayWithSecond replacing({int? hour, int? minute, int? seconds}) {
    return TimeOfDayWithSecond(
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        second: seconds ?? second);
  }

  @override
  String toString() {
    twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(minute);
    final twoDigitSeconds = twoDigits(second);
    return '$hour:$twoDigitMinutes:$twoDigitSeconds';
  }
}
