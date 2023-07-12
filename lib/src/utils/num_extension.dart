// ignore_for_file: comment_references

import 'package:flutter/material.dart';

/// An extension on [num] providing methods to convert [num] to [SizedBox]
extension NumToBox on num {
  /// Returns a [Sizedbox] with the passed value as [height]
  SizedBox get heightBox => SizedBox(height: toDouble());

  /// Returns a [Sizedbox] with the passed value as [height]
  SizedBox get widthBox => SizedBox(width: toDouble());
}
