import 'dart:io';
import 'package:mineai/config/flavor/flavor_config.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CustomAppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // colorful log messages
      printEmojis: true, // prints emoji for log levels
    ),
  );
  // Debug log
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (FlavorConfig.isDevelopment) {
      _logger.d(message, error: error, stackTrace: stackTrace);
      _saveToFile("DEBUG", message.toString());
    }
  }

  // Info log
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (FlavorConfig.isDevelopment) {
      _logger.i(message, error: error, stackTrace: stackTrace);
      _saveToFile("INFO", message.toString());
    }
  }

  // Warning log
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (FlavorConfig.isDevelopment) {
      _logger.w(message, error: error, stackTrace: stackTrace);
      _saveToFile("WARNING", message.toString());
    }
  }

  // Error log
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (FlavorConfig.isDevelopment) {
      _logger.e(message, error: error, stackTrace: stackTrace);
      _saveToFile("ERROR", message.toString());
    }
  }

  // Custom logger with tag
  static Future<void> appLogger(String tag, String message) async {
    final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final logEntry = "[$now] [$tag] $message";
    if (FlavorConfig.isDevelopment) _logger.t(logEntry); // log with TRACE level
    await _saveToFile(tag, message);
  }

  // Save logs into a file
  static Future<void> _saveToFile(String level, String message) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/app_logs.txt");
      final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      final logEntry = "[$now] [$level] $message\n";
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      if (FlavorConfig.isDevelopment) {
        _logger.e("Failed to write log to file", error: e);
      }
    }
  }

  // Read logs
  static Future<String> readLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/app_logs.txt");
      if (!await file.exists()) return "No logs found.";
      return await file.readAsString();
    } catch (e) {
      return "Failed to read logs: $e";
    }
  }

  // Clear logs
  static Future<void> clearLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/app_logs.txt");
      if (await file.exists()) {
        await file.writeAsString("");
      }
    } catch (e) {
      if (FlavorConfig.isDevelopment) {
        _logger.e("Failed to clear logs", error: e);
      }
    }
  }
}
