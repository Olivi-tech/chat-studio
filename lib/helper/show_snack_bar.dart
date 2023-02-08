import 'package:flutter/material.dart';
import 'package:studio_chat/main.dart';

class SnackBarHelper {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack(
      {required BuildContext context,
      required String msg,
      int? durationSeconds = 2}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        backgroundColor: msg == 'Success' ? Colors.green.shade300 : Colors.blue,
        duration: Duration(seconds: durationSeconds!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: mq.height * 0.01,
          left: mq.width * 0.05,
          right: mq.width * 0.05,
        )));
  }
}
