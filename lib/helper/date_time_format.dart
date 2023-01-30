import 'package:intl/intl.dart';

class DateTimeFormat {
  static String formatTime({required String time}) {
    return DateFormat.jm()
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));
  }

  static String getLastMessageTime(String time) {
    final sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();
    if (sent.day == now.day &&
        sent.month == now.month &&
        sent.year == now.year) {
      return DateFormat.jm()
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));
    } else {
      return '${sent.day} ${getMonth(sent)} ${sent.year}';
    }
  }

  static String getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
