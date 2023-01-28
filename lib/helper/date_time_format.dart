import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormat {
  static String formatTime(
      {required BuildContext context, required String time}) {
    return DateFormat.jm()
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));
  }
}
