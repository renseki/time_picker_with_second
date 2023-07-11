import 'package:flutter/material.dart';

/// To toggle/switch between 24 and 12 hour format
class HourFormatControl extends StatefulWidget {
  /// named constructor
  const HourFormatControl({super.key});

  @override
  State<HourFormatControl> createState() => _HourFormatControlState();
}

class _HourFormatControlState extends State<HourFormatControl> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // min and max width to avoid overflow
      constraints: const BoxConstraints(
        minWidth: 40,
        maxWidth: 80,
      ),
      // fixed height to be consistent with the other controls
      height: 40,
      // Text button to toggle between 24 and 12 hour format
      child: TextButton(
        onPressed: () {},
        child: const Text('24 Hour Format'),
      ),
    );
  }
}
