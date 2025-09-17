import 'package:intl/intl.dart';

// ----------------------
//  DATE/TIME HELPERS
// ----------------------

class DateTimeHelper {
  // Format DateTime to string
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  // Parse string to DateTime
  static DateTime? parseDate(String dateStr, {String format = 'yyyy-MM-dd'}) {
    try {
      return DateFormat(format).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Convert DateTime to time string
  static String formatTime(DateTime date, {String format = 'HH:mm'}) {
    return DateFormat(format).format(date);
  }

  // Get current date in given format
  static String getCurrentDate({String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(DateTime.now());
  }

  static String formatDateTime(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    return DateFormat('dd-MM-yyyy hh:mm:a').format(dateTime);
  }

  static String formatDateWithTimestamp(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static String formatTimeWithTimestamp(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    return DateFormat('hh:mm:a').format(dateTime);
  }

  static DateTime convertToDateTime(String dateTimeString) {
    try {
      DateFormat inputFormat = DateFormat("dd/MM/yyyy hh:mm a");
      DateTime dateTime = inputFormat.parse(dateTimeString);
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  String? convertToDateTimeString(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedDate = DateFormat('dd-MM HH:mm a').format(dateTime);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }

  static DateTime convertEpochToDateTime(int epochTime) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(
        epochTime * 1000,
        isUtc: true,
      ).toLocal();
    } catch (e) {
      print("Error converting epoch time: $e");
      return DateTime.now();
    }
  }

  static int convertToEpoch(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return dateTime.millisecondsSinceEpoch; // Returns epoch in milliseconds
  }

  static String convertEpochToReadableFormattedDate(int epochTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime);
    return DateFormat("MMM d yyyy h:mm a").format(dateTime);
  }

  static List<String> changeTime24To12HourFormat(List<String> times24Hour) {
    List<String> times12Hour = times24Hour.map((time) {
      // Parse time string to DateTime object
      DateTime dateTime = DateFormat("HH:mm").parse(time);
      // Format to 12-hour time with AM/PM
      return DateFormat("h:mm a").format(dateTime);
    }).toList();
    return times12Hour;
  }
}
