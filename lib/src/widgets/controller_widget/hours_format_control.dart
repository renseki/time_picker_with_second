import 'package:flutter/material.dart';

/// To toggle/switch between 24 and 12 hour format
class HourFormatControl extends StatefulWidget {
  /// named constructor
  const HourFormatControl({
    required this.is24HourFormat,
    required this.onToggle,
    super.key,
  });

  /// is 12 hour format
  final bool is24HourFormat;

  /// callback to toggle between 24 and 12 hour format
  final VoidCallback onToggle;

  @override
  State<HourFormatControl> createState() => _HourFormatControlState();
}

class _HourFormatControlState extends State<HourFormatControl> {
  @override
  Widget build(BuildContext context) {
    final currentFormat = widget.is24HourFormat ? '12' : '24';
    return Container(
      // min and max width to avoid overflow
      constraints: const BoxConstraints(
        minWidth: 40,
        maxWidth: 120,
      ),
      // fixed height to be consistent with the other controls
      height: 40,
      // Text button to toggle between 24 and 12 hour format
      child: TextButton(
        onPressed: widget.onToggle,
        child: Text('Use $currentFormat-Hour Format'),
      ),
    );
  }
}
