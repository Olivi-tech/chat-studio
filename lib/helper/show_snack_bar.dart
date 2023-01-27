import 'package:flutter/material.dart';

class SnackBarHelper {
  double? height;
  double? width;
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack(
      {required BuildContext context,
      required String msg,
      int? durationSeconds = 2}) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: msg == 'Success' ? Colors.green.shade300 : Colors.blue,
        duration: Duration(seconds: durationSeconds!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: height * 0.01,
          left: width * 0.05,
          right: width * 0.05,
        )));
  }
}
