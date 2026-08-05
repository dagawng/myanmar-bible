import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShortDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }
}
